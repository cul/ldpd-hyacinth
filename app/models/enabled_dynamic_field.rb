# frozen_string_literal: true

class EnabledDynamicField < ApplicationRecord
  # Below, we need to set join_table explicity because of a Rails 6.1 bug
  has_and_belongs_to_many :field_sets, join_table: 'enabled_dynamic_fields_field_sets'

  belongs_to :project, inverse_of: :enabled_dynamic_fields
  belongs_to :dynamic_field, inverse_of: :enabled_dynamic_fields

  validates :project, :dynamic_field, :digital_object_type, presence: true
  validates :digital_object_type, inclusion: { in: proc { Hyacinth::Config.digital_object_types.keys } }
  validates :dynamic_field, uniqueness: { scope: [:project, :digital_object_type] }

  before_destroy :disallow_destroy_if_field_in_use_by_project

  def disallow_destroy_if_field_in_use_by_project
    return unless Hyacinth::Config.digital_object_search_adapter.field_used_in_project?(dynamic_field.path, project, digital_object_type)
    self.errors.add(:destroy, "Cannot disable #{dynamic_field.display_label} because it's used by one or more #{digital_object_type.pluralize} in #{project.display_label}")
    throw :abort
  end

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
