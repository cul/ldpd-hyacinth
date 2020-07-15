# frozen_string_literal: true

module Types
  class PublishTargetType < Types::BaseObject
    description 'A publish target'

    field :type, Enums::PublishTargetTypeEnum, null: false, method: :target_type
    field :publish_url, String, null: false
    field :api_key, String, null: false
    field :doi_priority, Integer, null: false
    field :is_allowed_doi_target, Boolean, null: false
    field :combined_key, String, null: false, method: :combined_key
  end
end
