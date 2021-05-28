# frozen_string_literal: true

class DigitalObject::DescriptiveFieldsValidator < DigitalObject::DynamicFieldsValidator
  include DigitalObject::EnabledDynamicFieldsValidations

  def validate_each(digital_object, attribute, value)
    return if value.blank?

    enabled_field_errors(digital_object, value).each do |a|
      digital_object.errors.add(a[0], a[1])
    end

    map = Hyacinth::DynamicFieldsMap.new('descriptive').map

    generate_errors(digital_object, attribute, value, map)
  end
end
