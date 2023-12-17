class Fieldset < ApplicationRecord
  belongs_to :project
  has_many :enabled_dynamic_fields_fieldsets
  has_many :enabled_dynamic_fields, through: :enabled_dynamic_fields_fieldsets

  def as_json(_options = {})
    {
      id: id,
      display_label: display_label
    }
  end
end
