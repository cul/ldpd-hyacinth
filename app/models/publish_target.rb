class PublishTarget < ApplicationRecord
  has_and_belongs_to_many :projects
  has_and_belongs_to_many :digital_object_records

  validates :string_key, presence: true, uniqueness: true, format: { 
    with: /\A[a-z0-9_]+\z/,
    message: 'only allows lowercase letters, numbers and underscores'
  }
  validates :display_label, presence: true
  validates :publish_url, presence: true
  validates :api_key, presence: true
end