# frozen_string_literal: true

class FieldSet < ApplicationRecord
  has_and_belongs_to_many :enabled_dynamic_fields

  belongs_to :project

  validates :display_label, presence: true

  def as_json(_options = {})
    {
      id: id,
      display_label: display_label
    }
  end
end
