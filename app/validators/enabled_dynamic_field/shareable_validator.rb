# frozen_string_literal: true

class EnabledDynamicField::ShareableValidator < ActiveModel::Validator
  ERROR_MESSAGE = "Only primary projects are allowed to disable sharing dynamic fields"
  # validate that only permitted project types are limiting field access to other projects
  def validate(enabled_dynamic_field)
    return if enabled_dynamic_field.shareable || can_limit_field_access?(enabled_dynamic_field.project)
    enabled_dynamic_field.errors[:shareable] << ERROR_MESSAGE
  end

  def can_limit_field_access?(project)
    project&.is_primary
  end
end
