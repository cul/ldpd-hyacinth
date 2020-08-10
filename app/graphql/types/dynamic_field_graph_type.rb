# frozen_string_literal: true

module Types
  class DynamicFieldGraphType < Types::BaseObject
    description 'All the dynamic field data'

    field :dynamic_field_categories, [GraphQL::Types::JSON], null: false
  end
end
