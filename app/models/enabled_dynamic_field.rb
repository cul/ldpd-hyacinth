class EnabledDynamicField < ActiveRecord::Base

  belongs_to :project
  belongs_to :dynamic_field
  belongs_to :digital_object_type
  has_and_belongs_to_many :fieldsets

  validates :project, :dynamic_field, :digital_object_type, presence: true

  def as_json(options={})
    return {
      dynamic_field_id: self.dynamic_field_id,
      default_value: self.default_value,
      hidden: self.hidden,
      locked: self.locked,
      required: self.required,
      only_save_dynamic_field_group_if_present: self.only_save_dynamic_field_group_if_present,
      fieldset_ids: self.fieldset_ids

    }
  end

end
