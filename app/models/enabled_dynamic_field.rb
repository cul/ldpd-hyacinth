class EnabledDynamicField < ActiveRecord::Base
  belongs_to :project
  belongs_to :dynamic_field
  belongs_to :digital_object_type
  has_many :enabled_dynamic_fields_fieldsets
  has_many :fieldsets, through: :enabled_dynamic_fields_fieldsets

  validates :project, :dynamic_field, :digital_object_type, presence: true

  def as_json(_options = {})
    {
      dynamic_field_id: dynamic_field_id,
      default_value: default_value,
      hidden: hidden,
      locked: locked,
      required: required,
      only_save_dynamic_field_group_if_present: only_save_dynamic_field_group_if_present,
      fieldset_ids: fieldset_ids
    }
  end
end
