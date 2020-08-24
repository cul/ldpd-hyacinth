# frozen_string_literal: true
class StringKey::AbsentInSiblingFieldsValidator < ActiveModel::Validator
  def validate(dynamic_field_group)
    conditions = {
      string_key: dynamic_field_group.string_key,
      dynamic_field_group: dynamic_field_group.parent
    }
    conditions[:dynamic_field_group] = nil if dynamic_field_group.parent.is_a? DynamicFieldCategory
    return unless DynamicField.find_by(conditions)
    dynamic_field_group.errors.add(:string_key, "string_key #{dynamic_field_group.string_key} identifies a sibling DynamicField")
  end
end
