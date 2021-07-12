# frozen_string_literal: true

module Types
  class PublishTargetType < Types::BaseObject
    OBSCURED_API_KEY = "****************"

    description 'A publish target'

    field :string_key, ID, null: false
    field :publish_url, String, null: false
    field :api_key, String, null: false
    field :doi_priority, Integer, null: false
    field :is_allowed_doi_target, Boolean, null: false

    def api_key
      context[:current_user]&.admin? ? object.api_key : OBSCURED_API_KEY
    end
  end
end
