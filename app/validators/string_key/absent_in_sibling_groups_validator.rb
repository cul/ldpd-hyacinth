# frozen_string_literal: true

class StringKey::AbsentInSiblingGroupsValidator < ActiveModel::Validator
  def validate(dynamic_field)
    return unless DynamicFieldGroup.find_by(string_key: dynamic_field.string_key, parent: dynamic_field.dynamic_field_group)
    dynamic_field.errors.add(:string_key, "string_key #{dynamic_field.string_key} identifies a sibling DynamicFieldGroup")
  end
end
