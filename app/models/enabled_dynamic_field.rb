# frozen_string_literal: true

class EnabledDynamicField < ApplicationRecord
  has_and_belongs_to_many :field_sets

  belongs_to :project, inverse_of: :enabled_dynamic_fields
  belongs_to :dynamic_field, inverse_of: :enabled_dynamic_fields

  validates :project, :dynamic_field, :digital_object_type, presence: true
  validates :digital_object_type, inclusion: { in: Hyacinth::Config.digital_object_types.keys }
  validates :dynamic_field, uniqueness: { scope: [:project, :digital_object_type] }
  validates_with EnabledDynamicField::ShareableValidator

  def as_json(_options = {})
    {
      id: id,
      dynamic_field_id: dynamic_field_id,
      default_value: default_value,
      hidden: hidden,
      locked: locked,
      required: required,
      owner_only: owner_only,
      shareable: shareable,
      field_sets: field_sets
    }
  end
end
