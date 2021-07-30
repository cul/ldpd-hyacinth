# frozen_string_literal: true

class DigitalObject::DescriptiveFieldsValidator < DigitalObject::DynamicFieldsValidator
  include DigitalObject::EnabledDynamicFieldsValidations

  def validate_each(digital_object, attribute, value)
    return if value.blank?

    enabled_field_errors(digital_object.primary_project, digital_object.digital_object_type, value).each do |a|
      digital_object.errors.add(a[0], a[1])
    end

    generate_errors(attribute, value, Hyacinth::DynamicFieldsMap.new('descriptive').map).each do |a|
      digital_object.errors.add(a[0], a[1])
    end
  end
end
