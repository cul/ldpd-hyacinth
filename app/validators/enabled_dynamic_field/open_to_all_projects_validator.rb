# frozen_string_literal: true

class EnabledDynamicField::OpenToAllProjectsValidator < ActiveModel::Validator
  def validate(enabled_dynamic_field)
    return if enabled_dynamic_field.open_to_all_projects || enabled_dynamic_field.project&.is_primary
    enabled_dynamic_field.errors[:open_to_all_projects] << "Only primary projects have exclusively enabled dynamic fields"
  end
end
