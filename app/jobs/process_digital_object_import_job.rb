class ProcessDigitalObjectImportJob < ActiveJob::Base
  queue_as Hyacinth::Queue::DIGITAL_OBJECT_IMPORT_LOW

  UNEXPECTED_PROCESSING_ERROR_RETRY_DELAY = 60
  FIND_DIGITAL_OBJECT_IMPORT_RETRY_DELAY = 10

  def perform(digital_object_import_id)
    # If the import job was previously deleted (and does not exist in the database), return immediately
    return unless DigitalObjectImport.exists?(digital_object_import_id)

    # Retrieve DigitalObjectImport instance from table
    # If we encounter an error (e.g. Mysql2::Error), wait and try again.
    digital_object_import = find_digital_object_import_with_retry(digital_object_import_id)
    # If prerequisite check fails, return immediately.
    # Re-queueing or mark-as-failure logic is handled by the prerequisite_row_check method.
    return unless prerequisite_row_check(digital_object_import)

    user = digital_object_import.import_job.user
    digital_object_data = JSON.parse(digital_object_import.digital_object_data)

    digital_object = find_or_create_digital_object(digital_object_data, user, digital_object_import)
    result = assign_data(digital_object, digital_object_data, digital_object_import)

    3.times do
      break if result != :parent_not_found

      # If the parent wasn't found, wait 30 seconds (three times, with 10 second pauses)
      # in case the parent is currently being processed, or if solr hasn't auto-committed yet.
      sleep 10
      digital_object_import.digital_object_errors = [] # clear errors from last attempt
      result = assign_data(digital_object, digital_object_data, digital_object_import)
    end

    if result == :parent_not_found
      # The referenced parent object(s) still cannot be found, even after a
      # wait and retry, so we'll mark this as a failure.
      digital_object_import.digital_object_errors << "Failed because referenced parent object could not be found."
      digital_object_import.status = :failure
      digital_object_import.save!
      return
    else
      handle_success_or_failure(result, digital_object, digital_object_import, HYACINTH[:solr_commit_after_each_csv_import_row])
    end
  rescue StandardError => e
    handle_unexpected_processing_error(digital_object_import_id, e)
  end

  def find_or_create_digital_object(digital_object_data, user, digital_object_import)
    if existing_object?(digital_object_data)
      # We're updating data for an existing object
      existing_object_for_update(digital_object_data, user)
    else
      digital_object_type = digital_object_data['digital_object_type']['string_key'] if digital_object_data['digital_object_type']
      new_object(digital_object_type, user, digital_object_import)
    end
  end

  # Note that for this method, we pass the digital_object_import_id instead of a
  # digital_object_import instance because when it's called, we can't guarantee
  # that we were able to successfully obtain a digital_object_import instance.
  # We try multiple times, within this method, to obtain an instance.
  def handle_unexpected_processing_error(digital_object_import_id, e, queue_long_jobs = HYACINTH[:queue_long_jobs])
    # In the case of some unexpected, otherwise unhandled error, mark this job
    # as a failure so that it doesn't get stuck as pending forever, causing
    # other jobs that depend on it to be requeued forever.

    # Log error for debugging purposes
    Hyacinth::Utils::Logger.logger.error("#{self.class.name}: Encountered unexpected error while processing DigitalObjectImport with id #{digital_object_import_id}: ##{e.message}")

    # It is very important that we mark this job as a failure, and we want to
    # try multuple times, with long sleep delays, in case the unexpected error
    # is due to temporary unavailability of the database.
    Retriable.retriable(tries: 3, base_interval: UNEXPECTED_PROCESSING_ERROR_RETRY_DELAY) do
      digital_object_import = find_digital_object_import_with_retry(digital_object_import_id)
      digital_object_import.digital_object_errors << exception_with_backtrace_as_error_message(e)
      digital_object_import.status = :failure
      digital_object_import.save!
    end
  end

  def find_digital_object_import_with_retry(digital_object_import_id)
    # Retry in case database is briefly unavailable
    Retriable.retriable(tries: 3, base_interval: FIND_DIGITAL_OBJECT_IMPORT_RETRY_DELAY) do
      return DigitalObjectImport.find(digital_object_import_id)
    end
  end

  def existing_object?(digital_object_data)
    digital_object_data['pid'].present? && DigitalObject::Base.exists?(digital_object_data['pid'])
  end

  def assign_data(digital_object, digital_object_data, digital_object_import)
    digital_object.set_digital_object_data(digital_object_data, true)
    :success
  rescue Hyacinth::Exceptions::ParentDigitalObjectNotFoundError => e
    digital_object_import.digital_object_errors << e.message
    :parent_not_found
  rescue StandardError => e
    digital_object_import.digital_object_errors << exception_with_backtrace_as_error_message(e)
    :failure
  end

  def exception_with_backtrace_as_error_message(e)
    e.message + "\n<span class=\"backtrace\">Backtrace:\n\t#{e.backtrace.join("\n\t")}</span>"
  end

  def existing_object_for_update(digital_object_data, user)
    digital_object = DigitalObject::Base.find(digital_object_data['pid'])
    digital_object.updated_by = user
    digital_object
  end

  def new_object(digital_object_type, user, digital_object_import)
    digital_object = DigitalObjectType.get_model_for_string_key(digital_object_type || :missing).new
    digital_object.created_by = user
    digital_object.updated_by = user
    digital_object
  rescue Hyacinth::Exceptions::InvalidDigitalObjectTypeError => e
    digital_object_import.digital_object_errors << e.message
    nil
  end

  def handle_success_or_failure(status, digital_object, digital_object_import, do_solr_commit)
    if status == :success && digital_object.save(do_solr_commit)
      digital_object_import.digital_object_errors = []
      digital_object_import.status = :success
      digital_object_import.save!
    else # if status == :failure
      digital_object_import.digital_object_errors += digital_object.errors.full_messages if digital_object.present?
      digital_object_import.status = :failure
      digital_object_import.save!
    end
  end

  # Returns true if prerequisite rows have been processed successfully.
  # Returns false if prerequisite rows are still pending, or if they failed.
  # Returns false if digital_object_import's prerequisite rows include the digital_object_import's csv_row_number.
  # If prerequisite rows are pending, then this digital_object_import will be requeued.
  # If prerequisite rows failed, then this digital_object_import will also fail with
  # a prerequisite-related error message.
  def prerequisite_row_check(digital_object_import, queue_long_jobs = HYACINTH[:queue_long_jobs])
    # If this import has prerequisite_csv_row_numbers, make sure that the job
    # with that prerequisite_csv_row_numbers has been completed.  If it hasn't,
    # we'll re-queue this job.
    if digital_object_import.prerequisite_csv_row_numbers.present?
      prerequisite_csv_row_numbers = digital_object_import.prerequisite_csv_row_numbers
      # If prerequisite_row_numbers include THIS digital object import's csv_row number,
      # then mark this jobs as a failure and return a circular dependency error
      if prerequisite_csv_row_numbers.include?(digital_object_import.csv_row_number)
        digital_object_import.digital_object_errors << 'A CSV row cannot have itself as a prerequisite row. (Did you accidentally try to make this object its own parent?)'
        digital_object_import.status = :failure
        digital_object_import.save!
        return false
      end

      # Find the other jobs
      prerequisite_digital_object_imports = DigitalObjectImport.where(
        import_job: digital_object_import.import_job,
        csv_row_number: prerequisite_csv_row_numbers,
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
        digital_object_import.status = :failure
        digital_object_import.save!
        return false
      end

      # If there are no prerequisite object failures, check for
      # prerequisite objects that are pending. If we find pending
      # prerequisites, handle those first.
      if num_pending_prerequisites > 0
        handle_remaining_prerequisite_case(digital_object_import, queue_long_jobs)
        return false
      end

      return true
    end

    true
  end

  def handle_remaining_prerequisite_case(digital_object_import, queue_long_jobs)
    if queue_long_jobs
      # If prerequisite are still pending, then re-queue this import
      digital_object_import.digital_object_errors = [] # clear earlier errors if we're re-queueing
      digital_object_import.save!
      Hyacinth::Queue.process_digital_object_import(digital_object_import)
    else
      digital_object_import.digital_object_errors << "Failed because prerequisite rows haven't been processed and queue_long_jobs option is false, which means that spreadsheet rows are processed synchronously. Make sure that your CSV rows are in the order that you want them to be imported."
      digital_object_import.status = :failure
      digital_object_import.save!
    end
  end
end
