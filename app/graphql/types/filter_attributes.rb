# frozen_string_literal: true

module Types
  class FilterAttributes < Types::BaseInputObject
    description 'A field/value/function tuple that can be used to filter results'

    argument :field, String, required: true
    argument :value, String, required: true
    argument :match_type, Enums::FilterMatchEnum, default_value: 'EQUALS', required: false
  end
end
