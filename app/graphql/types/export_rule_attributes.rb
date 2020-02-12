# frozen_string_literal: true

module Types
  class ExportRuleAttributes < Types::BaseInputObject
    description 'Input type for export rules'

    argument :id, ID, required: false
    argument :field_export_profile_id, ID, required: false
    argument :translation_logic, GraphQL::Types::JSON, required: false
  end
end
