# frozen_string_literal: true

class DigitalObject::MetadataAttributesValidator < ActiveModel::Validator
  def validate(digital_object)
    digital_object.metadata_attributes.each do |metadata_attribute_name, type_def|
      value = digital_object.send(metadata_attribute_name)
      digital_object.errors[:metadata_attribute_name] << "Invalid value for #{metadata_attribute_name}" unless type_def.valid?(value)
    end
  end
end
