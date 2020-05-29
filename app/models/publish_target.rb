# frozen_string_literal: true

class PublishTarget < ApplicationRecord
  belongs_to :project

  validates :string_key, presence: true, uniqueness: true, string_key: true
  validates :display_label, :publish_url, :api_key, presence: true
  validates :doi_priority, numericality: {
    only_integer: true, allow_nil: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 100
  }

  def as_json(_options = {})
    {
      project: project.string_key,
      string_key: string_key,
      display_label: display_label,
      publish_url: publish_url,
      api_key: api_key,
      is_allowed_doi_target: is_allowed_doi_target,
      doi_priority: doi_priority
    }
  end

  def valid_doi_location?
    is_allowed_doi_target
  end
end
