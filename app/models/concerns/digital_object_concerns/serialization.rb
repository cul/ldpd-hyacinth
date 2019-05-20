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
        self.resource_attributes.each do |resource_attribute_name|
          json_var['resources'] ||= {}
          resource = resources[resource_attribute_name]&.to_serialized_form
          unless resource.blank?
            json_var['resources'][resource_attribute_name.to_s] = resource
          end
        end
        # serialize restriction_attributes
        self.restriction_attributes.each do |restriction_attribute_name, type_def|
          json_var['restrictions'] ||= {}
          value = type_def.to_serialized_form(restrictions[restriction_attribute_name])
          unless value.blank?
            json_var['restrictions'][restriction_attribute_name.to_s] = value
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
        digital_object.resource_attributes.map do |resource_name|
          resource_name = resource_name.to_s
          if json_var['resources']&.key?(resource_name)
            digital_object.resources[resource_name] = Hyacinth::DigitalObject::Resource.from_serialized_form(json_var['resources'][resource_name])
          end
        end
        # set restrictions
        digital_object.restriction_attributes.map do |restriction_name|
          restriction_name = restriction_name.to_s
          if json_var['restrictions']&.key?(restriction_name)
            type_def = digital_object.restriction_attributes[restriction_name]
            digital_object.restrictions[restriction_name] = type_def.from_serialized_form(json_var['restrictions'][restriction_name])
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
