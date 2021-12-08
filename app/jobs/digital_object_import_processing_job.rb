# frozen_string_literal: true

class DigitalObjectImportProcessingJob
  @queue = :digital_object_import_processing

  def self.perform(digital_object_import_id)
    digital_object_import = find_digital_object_import(digital_object_import_id)
    batch_import = digital_object_import.batch_import
    # If the parent BatchImport has been cancelled, do not run this job.
    if batch_import.cancelled
      apply_recursive_cancellation!(digital_object_import)
      return
    end

    # As a safety measure, make sure that a job that was started is never accidentally re-queued
    # by any means (rails console, manual resque job restart, etc.) because this could lead to
    # duplicate object creation in certain situations.
    return unless ['pending', 'queued'].include?(digital_object_import.status)

    # Mark this DigitalObjectImport as in progress
    digital_object_import.in_progress!
    digital_object_data = JSON.parse(digital_object_import.digital_object_data)
    digital_object = digital_object_for_digital_object_data(digital_object_data)

    # Update the DigitalObject's attributes with the given digital_object_data
    digital_object.assign_attributes(digital_object_data)
    digital_object.created_by = batch_import.user if digital_object.new_record?
    digital_object.updated_by = batch_import.user

    # Save the object, and terminate processing if the save fails.
    unless digital_object.save
      digital_object_import.import_errors = digital_object.errors.map { |error| "#{error.attribute}: #{error.message}" }
      # Apply a recursive failure to this digital_object_import and all other DigitalObjectImports
      # that depend on it, since it doesn't make sense to run the others if this one failed.
      apply_recursive_failure!(digital_object_import)
      return
    end

    # Mark this digital object import as successful
    digital_object_import.success!
    queue_applicable_import_prerequisites(digital_object_import)
  rescue StandardError => e
    handle_job_error(digital_object_import, e)
  end

  def self.digital_object_for_digital_object_data(digital_object_data)
    if digital_object_data['assign_uid'].present?
      raise ArgumentError, 'Either "uid" or "assign_uid" attribute may be present in digital_object_data, but not both.' if digital_object_data['uid'].present?
      raise ArgumentError, 'Cannot create new digital object with "assign_uid"; object with same uid already exists' if DigitalObject.find_by_uid(digital_object_data['assign_uid'])
      raise ArgumentError, 'Cannot create new digital object with "assign_uid"; digital object type is required' unless digital_object_data['digital_object_type'].present?
      # assign_uid present, so we'll create a new object with type based on the digital_object_type value
      Hyacinth::Config.digital_object_types.key_to_class(digital_object_data['digital_object_type']).new
    elsif digital_object_data['uid'].present?
      # If a uid is present in the digital_object_data, then this is an update operation
      DigitalObject.find_by_uid!(digital_object_data['uid'])
    else
      raise ArgumentError, 'Unable to find or create digital object because "uid" or “assign_uid”/"digital_object_type" attributes were not present in digital_object_data.'
    end
  end

  def self.apply_recursive_failure!(digital_object_import)
    dod = JSON.parse(digital_object_import.digital_object_data)
    dod['uid'].present? ? digital_object_import.update_failure! : digital_object_import.creation_failure!

    # Find all DigitalObjectImports for which this DigitalObjectImport was a prerequisite.
    ImportPrerequisite.where(prerequisite_digital_object_import: digital_object_import).each do |import_prerequisite|
      dependent_digital_object_import = import_prerequisite.digital_object_import
      dependent_digital_object_import.import_errors << "Failed because prerequisite Digital Object Import failed. Prerequisite Row = #{digital_object_import.index}"
      apply_recursive_failure!(dependent_digital_object_import)
    end
  end

  def self.apply_recursive_cancellation!(digital_object_import)
    digital_object_import.cancelled!

    # Find all DigitalObjectImports for which this DigitalObjectImport was a prerequisite.
    ImportPrerequisite.where(prerequisite_digital_object_import: digital_object_import).each do |import_prerequisite|
      dependent_digital_object_import = import_prerequisite.digital_object_import
      apply_recursive_cancellation!(dependent_digital_object_import)
    end
  end

  def self.queue_applicable_import_prerequisites(digital_object_import)
    # Now we'll find and destroy all ImportPrerequisites that this DigitalObjectImport was a
    # prerequisite for, but store the returned object values so we can queue their processing next.
    destroyed_import_prerequisites = ImportPrerequisite.where(prerequisite_digital_object_import: digital_object_import).destroy_all

    # Get the associated DigitalObjectImport for each deleted ImportPrerequisite, establish a lock
    # on that DigitalObjectImport, and check if it has any other ImportPrerequisite.  If not, queue
    # it for processing.
    # Why are we locking on the DigitalObjectImport before we check its ?  Because it's possible that if it had
    # two ImportPrerequisite that happened to be processed asynchronously at the same time,
    # there may be two DigitalObjectImportProcessingJobs attempting to queue a new
    # DigitalObjectImportProcessingJob for the same DigitalObjectImport.
    destroyed_import_prerequisites.each do |destroyed_import_prerequisite|
      digital_object_import_to_queue = destroyed_import_prerequisite.digital_object_import
      digital_object_import_to_queue.with_lock do
        # Remember: with_lock also reload the object so we have the latest status value.

        # Don't queue this object if it has already been queued.
        next if digital_object_import_to_queue.queued?
        # Don't queue this object if it still has other ImportPrerequisites.
        next if digital_object_import_to_queue.import_prerequisites.present?

        digital_object_import_to_queue.queued!
        Resque.enqueue(DigitalObjectImportProcessingJob, digital_object_import_to_queue.id)
      end
    end
  end

  def self.find_digital_object_import(digital_object_import_id)
    DigitalObjectImport.includes(:batch_import).find(digital_object_import_id)
  end

  def self.handle_job_error(digital_object_import, error)
    digital_object_import.import_errors <<
      error.message + "\n\n"\
      "See application error log for more details.\n"\
      "Message generated at #{Time.current}"
    Rails.logger.error(error.message + "\n" + error.backtrace.join("\n"))
    apply_recursive_failure!(digital_object_import)
  end
end
