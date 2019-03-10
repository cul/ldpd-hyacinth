module DigitalObjectConcerns::FindBehavior
  extend ActiveSupport::Concern

  module ClassMethods
    def find(uid)
      # Important note: We don't want to do a lock when finding. That would
      # mess up other code that assumes no locking during find operations.
      # The optimistic_lock_token exists so that we don't need to lock on find
      # operations. We can find any time we want, but when we save we'll be
      # notified if another person saved and made our object instance stale.
      digital_object_record = DigitalObjectRecord.find_by(uid: uid)
      raise Hyacinth::Exceptions::NotFound, "Could not find DigtalObject with uid #{uid}" if digital_object_record.nil?
      digital_object_data = JSON.parse(Hyacinth.config.metadata_storage.read(digital_object_record.metadata_location_uri))
      digital_object = Hyacinth.config.digital_object_types.key_to_class(digital_object_data['digital_object_type'])
      # set metadata_attributes
      digital_object.metadata_attributes.map do |metadata_attribute_name, type_def|
        digital_object.send(metadata_attribute_name + '=', type_def.attribute_from_digital_object_data(digital_object_data[metadata_attribute_name.to_s]))
      end
      # build resource objects
      digital_object.resource_attributes.map do |resource_name, resource|
        digital_object.send(resource_name + '=', Hyacinth::DigitalObject::Resource.from_json(digital_object_data['resources'][resource_name]))
      end
      # set digital_object_record
      digital_object.instance_variable_set('@digital_object_record', digital_object_record)
      # set optimistic_lock_token
      digital_object.instance_variable_set('@optimistic_lock_token', digital_object_record.optimistic_lock_token)
      # return built object
      digital_object
    end
  end
end
