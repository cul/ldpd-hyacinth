class Group < ApplicationRecord
  has_and_belongs_to_many :users
  has_many :permissions

  validates :string_key, presence: true, uniqueness: true, string_key: true

  def as_json(_options = {})
    {
      string_key: string_key
    }
  end
end
