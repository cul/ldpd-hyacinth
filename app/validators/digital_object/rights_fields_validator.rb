# frozen_string_literal: true

class DigitalObject::RightsFieldsValidator < DigitalObject::DynamicFieldsValidator
  def validate_each(digital_object, attribute, value)
    return if value.blank?

    # Rights can only be assigned to Items and Assets.
    unless digital_object.can_have_rights?
      digital_object.errors.add(:rights, "cannot be assigned for #{digital_object.digital_object_type}")
      return
    end

    generate_errors(attribute, value, Hyacinth::DynamicFieldsMap.new("#{digital_object.digital_object_type}_rights").map).each do |a|
      digital_object.errors.add(a[0], a[1])
    end
  end
end
