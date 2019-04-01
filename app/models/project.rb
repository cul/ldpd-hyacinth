class Project < ApplicationRecord
  has_many :publish_targets
  has_many :enabled_dynamic_fields, dependent: :destroy

  validates :string_key, presence: true, uniqueness: true, string_key: true
  validates :display_label, presence: true, uniqueness: true
end
