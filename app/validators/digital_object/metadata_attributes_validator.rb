# frozen_string_literal: true

class DigitalObject::MetadataAttributesValidator < ActiveModel::Validator
  def validate(digital_object)
    digital_object.metadata_attributes.each do |metadata_attribute_name, type_def|
      value = digital_object.send(metadata_attribute_name)
      next if type_def.valid?(value)
      digital_object.errors.add(:metadata_attribute_name, "Invalid value for #{metadata_attribute_name}")
    end
  end
end
