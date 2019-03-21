module DigitalObjectConcerns
  module Serialization
    extend ActiveSupport::Concern

    def to_serialized_form
      {}.tap do |digital_object_data|
        # serialize metadata_attributes
        self.metadata_attributes.each do |metadata_attribute_name, type_def|
          digital_object_data[metadata_attribute_name.to_s] = type_def.to_serialized_form(self.send(metadata_attribute_name))
        end
        # serialize resource_attributes
        self.resource_attributes.each do |resource_attribute_name, resource|
          digital_object_data['resources'] ||= {}
          unless resource.nil?
            digital_object_data['resources'][resource_attribute_name.to_s] = resource.as_json
          end
        end
      end
    end


    module ClassMethods
      # # Creates a new DigitalObject from an existing DigitalObject instance, including metadata_attributes and resources.
      # # Deliberately DOES NOT duplicate the state of plain instance variables (like @publish_to or @mint_doi).
      # # This is effectively like persisting an object and then running find on that object, except that the entire
      # # operation runs in memory and nothing is persisted.
      # def from_instance(digital_object)
      #   DigitalObject.from_serialized_formdigital_object_record, digital_object.to_serialized_form)
      # end

      def from_serialized_form(digital_object_record, json_var)
        digital_object = Hyacinth.config.digital_object_types.key_to_class(json_var['digital_object_type']).new
        # set metadata_attributes
        digital_object.metadata_attributes.map do |metadata_attribute_name, type_def|
          digital_object.send("#{metadata_attribute_name}=",
            type_def.from_serialized_form(json_var[metadata_attribute_name.to_s]))
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
end
