class DigitalObjectConcerns::Validations::DigitalObjectTypeValidator < ActiveModel::Validator
  def validate(digital_object)
    return if Hyacinth.config.digital_object_types.include?(digital_object.digital_object_type)
    record.errors[:digital_object_type] << "Unregistered digital object type #{digital_object.digital_object_type}"
  end
end