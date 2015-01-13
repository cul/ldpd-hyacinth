class Fieldset < ActiveRecord::Base
  belongs_to :project
  has_and_belongs_to_many :enabled_dynamic_fields

  def as_json(options={})
    return {
      id: self.id,
      display_label: self.display_label
    }
  end
end
