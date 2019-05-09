module DigitalObjectConcerns
  module Serialization
    extend ActiveSupport::Concern

    def to_serialized_form
      {}.tap do |json_var|
        # serialize metadata_attributes
        self.metadata_attributes.each do |metadata_attribute_name, type_def|
          json_var[metadata_attribute_name.to_s] = type_def.to_serialized_form(self.send(metadata_attribute_name))
        end
        # serialize resource_attributes
        self.resource_attributes.each do |resource_attribute_name, resource|
          json_var['resources'] ||= {}
          unless resource.nil?
            json_var['resources'][resource_attribute_name.to_s] = resource.as_json
          end
        end
      end
    end

    module ClassMethods
      def from_serialized_form(digital_object_record, json_var)
        reject_unhandled_serialization_version!(json_var['serialization_version'])
        digital_object = Hyacinth.config.digital_object_types.key_to_class(json_var['digital_object_type']).new
        # set metadata_attributes
        digital_object.metadata_attributes.map do |metadata_attribute_name, type_def|
          digital_object.send("#{metadata_attribute_name}=",
            type_def.from_serialized_form(json_var[metadata_attribute_name.to_s]))
        end
        # build resource objects
        digital_object.resource_attributes.map do |resource_name, resource|
          if json_var['resources']&.key?(resource_name)
            digital_object.send("#{resource_name}=", Hyacinth::DigitalObject::Resource.from_serialized_form(json_var['resources'][resource_name]))
          end
        end
        # set digital_object_record
        digital_object.instance_variable_set('@digital_object_record', digital_object_record)
        # return built object
        digital_object
      end

      def reject_unhandled_serialization_version!(serialization_version)
        return if serialization_version == DigitalObject::Base::SERIALIZATION_VERSION
        raise Hyacinth::Exceptions::Deserialization,
          "Unexpected serialization version: #{serialization_version}. "\
          "At this time, we don't support upgrades from older Digital Object serialization versions."
      end
    end
  end
end
