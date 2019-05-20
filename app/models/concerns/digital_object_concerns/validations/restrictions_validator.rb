class DigitalObjectConcerns::Validations::RestrictionsValidator < ActiveModel::Validator
  def validate(digital_object)
    digital_object.restriction_attributes.each do |restriction_name, type_def|
      value = digital_object.restrictions[restriction_name]
      digital_object.errors[:restrictions] << "Invalid #{restriction_name} value #{value}" unless type_def.valid?(value)
    end
  end
end
