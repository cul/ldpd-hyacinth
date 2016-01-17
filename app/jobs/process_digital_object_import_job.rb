class ProcessDigitalObjectImportJob
  @queue = Hyacinth::Queue::DIGITAL_OBJECT_IMPORT
  MAX_REQUEUES = 3

  def self.perform(digital_object_import_id)
    # Retrieve DigitalObjectImport instance from table
    digital_object_import = DigitalObjectImport.find(digital_object_import_id)

    # User who created this job
    user = digital_object_import.import_job.user

    digital_object_data = JSON.parse(digital_object_import.digital_object_data)

    if digital_object_data['pid'].present?
      digital_object = existing_object_for_update(digital_object_data, user, digital_object_import)
    else
      digital_object = new_object(digital_object_data, user, digital_object_import)
    end

    status = assign_data(digital_object, digital_object_data, digital_object_import)

    return if status == :requeued

    handle_success_or_failure(status, digital_object, digital_object_import)
  end

  def self.handle_success_or_failure(status, digital_object, digital_object_import)
    if status == :success && digital_object.save
      digital_object_import.success!
    else # if status == :failure
      digital_object_import.digital_object_errors += digital_object.errors.full_messages if digital_object.present?
      digital_object_import.failure!
    end
  end

  def self.assign_data(digital_object, digital_object_data, digital_object_import)
    return :failure unless digital_object.present?
    digital_object.set_digital_object_data(digital_object_data, true)
    :success
  rescue Hyacinth::Exceptions::ParentDigitalObjectNotFoundError => e
    digital_object_import.digital_object_errors << e.message
    requeue_job(digital_object_import)
  rescue Hyacinth::Exceptions::NotFoundError => e
    digital_object_import.digital_object_errors << e.message
    :failure
  end

  def self.requeue_job(digital_object_import)
    digital_object_import.requeue_count += 1
    digital_object_import.save!
    if digital_object_import.requeue_count <= MAX_REQUEUES
      Hyacinth::Queue.process_digital_object_import(digital_object_import.id)
      :requeued
    else
      :failure
    end
  end

  def self.existing_object_for_update(digital_object_data, user, digital_object_import)
    digital_object = DigitalObject::Base.find(digital_object_data['pid'])
    digital_object.updated_by = user
    digital_object
  rescue Hyacinth::Exceptions::DigitalObjectNotFoundError => e
    digital_object_import.digital_object_errors << e.message
    nil
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
end
