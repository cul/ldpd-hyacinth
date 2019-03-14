module DigitalObjectConcerns::Serializer
  def to_serialized_form
    {}.tap do |digital_object_data|
      # serialize metadata_attributes
      self.metadata_attributes.map do |metadata_attribute_name, type_def|
        digital_object_data[metadata_attribute_name.to_s] = type_def.to_serialized_form(self.send(metadata_attribute_name))
      end
      # serialize resource_attributes
      self.resource_attributes.map do |resource_attribute_name, resource|
        digital_object_data['resources'] ||= {}
        unless resource.nil?
          digital_object_data['resources'][resource_attribute_name.to_s] = resource.as_json
        end
      end
    end
  end
end
