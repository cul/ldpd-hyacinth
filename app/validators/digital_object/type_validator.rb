# frozen_string_literal: true

class DigitalObject::TypeValidator < ActiveModel::Validator
  def validate(digital_object)
    return if Hyacinth::Config.digital_object_types.include?(digital_object.digital_object_type)
    digital_object.errors[:digital_object_type] << "Unregistered digital object type #{digital_object.digital_object_type}"
  end
end
