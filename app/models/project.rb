class Project < ApplicationRecord
  has_many :publish_targets

  validates :string_key, presence: true, uniqueness: true, string_key: true
  validates :display_label, presence: true, uniqueness: true
end
