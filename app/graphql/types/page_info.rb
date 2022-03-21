# frozen_string_literal: true

module Types
  # The return type of a connection's `pageInfo` field
  class PageInfo < Types::BaseObject
    description "Information about pagination in a search results."

    field :has_next_page, Boolean, null: false,
      description: "When paginating forwards, are there more items?"

    field :has_previous_page, Boolean, null: false,
      description: "When paginating backwards, are there more items?"
  end
end
