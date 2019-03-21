class PublishTarget < ApplicationRecord
  belongs_to :project

  validates :string_key, presence: true, uniqueness: true, string_key: true
  validates :display_label, :publish_url, :api_key, presence: true

  def as_json(_options = {})
    {
      project: project.string_key,
      string_key: string_key,
      display_label: display_label,
      publish_url: publish_url,
      api_key: api_key
    }
  end
end
