# frozen_string_literal: true

module Types
  module DigitalObject
    class PublishEntryType < Types::BaseObject
      description 'A publish entry'

      field :publish_target, PublishTargetType, null: false
      field :published_at, GraphQL::Types::ISO8601DateTime, null: false
      field :published_by, UserType, null: true
      field :citation_location, String, null: false
    end
  end
end
