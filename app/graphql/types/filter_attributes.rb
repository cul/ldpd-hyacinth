# frozen_string_literal: true

module Types
  class FilterAttributes < Types::BaseInputObject
    description 'A field/values/function tuple that can be used to filter results'

    argument :field, String, required: true
    argument :values, [String], required: true
    argument :match_type, Enums::FilterMatchEnum, default_value: 'equals', required: false
  end
end
