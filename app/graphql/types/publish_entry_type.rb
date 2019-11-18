module Types
  class PublishEntryType < Types::BaseObject
    description 'A publish entry'

    field :published_at, GraphQL::Types::ISO8601DateTime, null: false
    field :published_by, UserType, null: false
    field :cited_at, String, null: false
  end
end
