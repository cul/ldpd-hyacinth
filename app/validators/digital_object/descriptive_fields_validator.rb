# frozen_string_literal: true

class DigitalObject::DescriptiveFieldsValidator < DigitalObject::DynamicFieldsValidator
  def validate_each(digital_object, attribute, value)
    return if value.blank?

    map = Hyacinth::DynamicFieldsMap.new('descriptive').map

    generate_errors(digital_object, attribute, value, map, true)
  end
end
