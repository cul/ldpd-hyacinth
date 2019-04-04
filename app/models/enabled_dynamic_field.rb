class EnabledDynamicField < ApplicationRecord
  has_and_belongs_to_many :field_sets

  belongs_to :project
  belongs_to :dynamic_field

  validates :project, :dynamic_field, :digital_object_type, presence: true
  validates :digital_object_type, inclusion: { in: ['item', 'asset', 'site'] }
  validates :dynamic_field, uniqueness: { scope: [:project, :digital_object_type] }

  def as_json(_options = {})
    {
      id: id,
      dynamic_field_id: dynamic_field_id,
      default_value: default_value,
      hidden: hidden,
      locked: locked,
      required: required,
      owner_only: owner_only
      # fieldset_ids: fieldset_ids
    }
  end
end
