class ProcessDigitalObjectImportJob
  @queue = Hyacinth::Queue::DIGITAL_OBJECT_IMPORT

  def self.perform(digital_object_import_id)
    # Retrieve DigitalObjectImport instance from table
    digital_object_import = DigitalObjectImport.find(digital_object_import_id)

    # If prerequisite check fails, return immediately.
    # Re-queueing or mark-as-failure logic is handled by the prerequisite_row_check method.
    return unless prerequisite_row_check(digital_object_import)

    user = digital_object_import.import_job.user
    digital_object_data = JSON.parse(digital_object_import.digital_object_data)

    if existing_object?(digital_object_data)
      # We're updating data for an existing object
      digital_object = existing_object_for_update(digital_object_data, user, digital_object_import)
    else
      digital_object = new_object(digital_object_data, user, digital_object_import)
    end

    result = assign_data(digital_object, digital_object_data, digital_object_import)

    if result == :parent_not_found
      # If the parent wasn't found, wait 30 seconds in case the parent is
      # currently being processed, or if solr hasn't auto-committed yet,
      # and then try one more time.
      sleep 30
      digital_object_import.digital_object_errors = [] # clear errors from last attempt
      result = assign_data(digital_object, digital_object_data, digital_object_import)
    end

    if result == :parent_not_found
      # The referenced parent object(s) still cannot be found, even after a
      # wait and retry, so we'll mark this as a failure.
      digital_object_import.digital_object_errors << "Failed because referenced parent object could not be found."
      digital_object_import.failure!
      digital_object_import.save!
      return
    else
      handle_success_or_failure(result, digital_object, digital_object_import)
    end
  end

  def self.existing_object?(digital_object_data)
    digital_object_data['pid'].present? && DigitalObject::Base.exists?(digital_object_data['pid'])
  end

  def self.assign_data(digital_object, digital_object_data, digital_object_import)
    digital_object.set_digital_object_data(digital_object_data, true)
    :success
  rescue Hyacinth::Exceptions::ParentDigitalObjectNotFoundError => e
    digital_object_import.digital_object_errors << e.message
    :parent_not_found
  rescue Exception => e
    digital_object_import.digital_object_errors << e.message + '<span class="backtrace">' + "Backtrace:\n\t#{e.backtrace.join("\n\t")}" + '</span>'
    :failure
  end

  def self.existing_object_for_update(digital_object_data, user, digital_object_import)
    digital_object = DigitalObject::Base.find(digital_object_data['pid'])
    digital_object.updated_by = user
    digital_object
  end

  def self.new_object(digital_object_data, user, digital_object_import)
    digital_object = DigitalObjectType.get_model_for_string_key(digital_object_data['digital_object_type']['string_key']).new
    digital_object.created_by = user
    digital_object.updated_by = user
    digital_object
  rescue Hyacinth::Exceptions::InvalidDigitalObjectTypeError => e
    digital_object_import.digital_object_errors << e.message
    nil
  end

  def self.handle_success_or_failure(status, digital_object, digital_object_import)
    if status == :success && digital_object.save(HYACINTH['solr_commit_after_each_csv_import_row'])
      digital_object_import.digital_object_errors = []
      digital_object_import.success!
      digital_object_import.save! # TODO: Is save! necessary after calling "success!" ?
    else # if status == :failure
      digital_object_import.digital_object_errors += digital_object.errors.full_messages if digital_object.present?
      digital_object_import.failure!
      digital_object_import.save! # TODO: Is save! necessary after calling "failure!" ?
    end
  end

  # Returns true if prerequisite rows have been processed successfully
  # Returns false if prerequisite rows are still pending, or if they failed.
  # If prerequisite rows are pending, then this digital_object_import will be requeued.
  # If prerequisite rows failed, then this digital_object_import will also fail with
  # a prerequisite-related error message.
  def self.prerequisite_row_check(digital_object_import)
    # If this import has prerequisite_csv_row_numbers, make sure that the job
    # with that prerequisite_csv_row_numbers has been completed.  If it hasn't,
    # we'll re-queue this job.
    if digital_object_import.prerequisite_csv_row_numbers.present?
      # Find the other jobs
      prerequisite_digital_object_imports = DigitalObjectImport.where(
        import_job: digital_object_import.import_job,
        csv_row_number: digital_object_import.prerequisite_csv_row_numbers,
      )

      # If any of the prerequisite jobs have failed, mark this job as a failure
      # and provide an error message explaining that this job failed because its
      # prerequisite row failed (and give the failing prerequisite row id in the message)
      num_failed_prerequisites = 0
      num_pending_prerequisites = 0

      prerequisite_digital_object_imports.each do |prerequisite_digital_object_import|
        if prerequisite_digital_object_import.failure?
          num_failed_prerequisites += 1
          digital_object_import.digital_object_errors << "Failed because prerequisite row #{prerequisite_digital_object_import.csv_row_number} failed to import properly"
        end
        num_pending_prerequisites += 1 if prerequisite_digital_object_import.pending?
      end

      if num_failed_prerequisites > 0
        digital_object_import.save!
        return false
      end

      # If there are no prerequisite object failures, check for
      # prerequisite objects that are pending. If we find pending
      # prerequisites, handle those first.
      if num_pending_prerequisites > 0
        handle_remaining_prerequisite_case(digital_object_import)
        return false
      end

      return true
    end

    true
  end

  def handle_remaining_prerequisite_case(digital_object_import)
    if HYACINTH['queue_long_jobs']
      # If prerequisite are still pending, then re-queue this import
      digital_object_import.digital_object_errors = [] # clear earlier errors if we're re-queueing
      digital_object_import.save!
      Hyacinth::Queue.process_digital_object_import(digital_object_import.id)
    else
      digital_object_import.digital_object_errors << "Failed because prerequisite rows haven't been processed and queue_long_jobs option is false, which means that spreadsheet rows are processed synchronously. Make sure that your CSV rows are in the order that you want them to be imported."
      digital_object_import.failure!
      digital_object_import.save!
    end
  end
end
