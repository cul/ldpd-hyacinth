class Project < ApplicationRecord
  has_many :publish_targets,        dependent: :destroy
  has_many :enabled_dynamic_fields, dependent: :destroy, inverse_of: :project
  has_many :field_sets,             dependent: :destroy

  accepts_nested_attributes_for :enabled_dynamic_fields, allow_destroy: true

  validates :string_key, presence: true, uniqueness: true, string_key: true
  validates :display_label, presence: true, uniqueness: true
end
