module DigitalObjectConcerns::FindBehavior
  extend ActiveSupport::Concern

  module ClassMethods

    # Check whether an object with the given uid exists
    # @param uid [String] uid to search for
    def exists?(uid)
      DigitalObjectRecord.exists?(uid: uid)
    end

    def find(uid)
      # Important note: We don't want to do a lock when finding. That would
      # mess up other code that assumes no locking during find operations.
      # The optimistic_lock_token exists so that we don't need to lock on find
      # operations. We can find any time we want, but when we save we'll be
      # notified if another person saved and made our object instance stale.
      digital_object_record = DigitalObjectRecord.find_by(uid: uid)
      raise Hyacinth::Exceptions::NotFound, "Could not find DigtalObject with uid: #{uid}" if digital_object_record.nil?
      json_var = JSON.parse(Hyacinth.config.metadata_storage.read(digital_object_record.metadata_location_uri))
      digital_object = Hyacinth.config.digital_object_types.key_to_class(json_var['digital_object_type']).new
      # set metadata_attributes
      digital_object.metadata_attributes.map do |metadata_attribute_name, type_def|
        value = type_def.from_serialized_form(json_var[metadata_attribute_name.to_s])
        value.freeze if type_def.freeze_on_deserialize?
        digital_object.send("#{metadata_attribute_name}=", value)
      end
      # build resource objects
      digital_object.resource_attributes.map do |resource_name, resource|
        if json_var['resources'].key?(resource_name)
          digital_object.send("#{resource_name}=", Hyacinth::DigitalObject::Resource.from_serialized_form(json_var['resources'][resource_name]))
        end
      end
      # set digital_object_record
      digital_object.instance_variable_set('@digital_object_record', digital_object_record)
      # return built object
      digital_object
    end
  end
end
