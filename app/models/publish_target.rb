# frozen_string_literal: true

class PublishTarget < ApplicationRecord
  module Type
    PRODUCTION = 'production'
    STAGING = 'staging'
  end

  TYPES = [Type::PRODUCTION, Type::STAGING].freeze

  belongs_to :project

  validates :publish_url, :api_key, :target_type, presence: true

  validates :target_type, inclusion: { in: TYPES }, unless: proc { |a| a.target_type.nil? }
  validates :doi_priority, numericality: {
    only_integer: true, allow_nil: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 100
  }

  def as_json(_options = {})
    {
      project: project.string_key,
      type: type,
      publish_url: publish_url,
      api_key: api_key,
      is_allowed_doi_target: is_allowed_doi_target,
      doi_priority: doi_priority
    }
  end

  def valid_doi_location?
    is_allowed_doi_target
  end

  def combined_key
    "#{project.string_key}_#{target_type}"
  end

  def self.parse_combined_key(combined_key)
    match_data = /^(.+)_(#{PublishTarget::TYPES.join('|')})$/.match(combined_key)
    [match_data[1], match_data[2]]
  end
end
