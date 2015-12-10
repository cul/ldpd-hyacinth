class ProcessDigitalObjectImportJob

  @queue = Hyacinth::Queue::DIGITAL_OBJECT_IMPORT

  def self.perform(digital_object_import_id)

    # Retrieve DigitalObjectImport instance from table
    digital_object_import = DigitalObjectImport.find(digital_object_import_id)
    
    # User who created this job
    user = digital_object_import.import_job.user
    
    digital_object_data = JSON.parse(digital_object_import.digital_object_data)
    
    begin
      @digital_object = DigitalObjectType.get_model_for_string_key(digital_object_data['digital_object_type']['string_key']).new()
    rescue Hyacinth::Exceptions::InvalidDigitalObjectTypeError
      digital_object_import.digital_object_errors << 'Invalid digital_object_type specified: digital_object_type => ' + digital_object_data['digital_object_type'].inspect
    end
    
    begin
      @digital_object.set_digital_object_data(digital_object_data, true)
    rescue Hyacinth::Exceptions::PublishTargetNotFoundError, Hyacinth::Exceptions::DigitalObjectNotFoundError, Hyacinth::Exceptions::ParentDigitalObjectNotFoundError, Hyacinth::Exceptions::ProjectNotFoundError => e
       digital_object_import.digital_object_errors << e.message
    end
    
    @digital_object.created_by = user
    @digital_object.updated_by = user
    
    if digital_object_import.digital_object_errors.blank? && @digital_object.save
      digital_object_import.success!
    else
      digital_object_import.digital_object_errors += @digital_object.errors.full_messages
      digital_object_import.failure!
    end

    puts "Done Processing"

  end

end
