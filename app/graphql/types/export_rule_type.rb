# frozen_string_literal: true

module Types
  class ExportRuleType < Types::BaseObject
    description 'An export rule'

    field :id, ID, null: false
    field :field_export_profile, FieldExportProfileType, null: false
    field :translation_logic, GraphQL::Types::JSON, null: false
  end
end
