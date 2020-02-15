# frozen_string_literal: true

module Types
  class FieldExportProfileType < Types::BaseObject
    description 'A field export profile'

    field :id, ID, null: false
    field :name, String, null: false
    field :translation_logic, GraphQL::Types::JSON, null: false
  end
end
