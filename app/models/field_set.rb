# frozen_string_literal: true

class FieldSet < ApplicationRecord
  # Below, we need to set join_table explicity because of a Rails 6.1 bug
  has_and_belongs_to_many :enabled_dynamic_fields, join_table: 'enabled_dynamic_fields_field_sets'

  belongs_to :project

  validates :display_label, presence: true

  def as_json(_options = {})
    {
      id: id,
      display_label: display_label
    }
  end
end
