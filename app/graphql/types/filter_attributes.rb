# frozen_string_literal: true

module Types
  class FilterAttributes < Types::BaseInputObject
    description 'A field/values/function tuple that can be used to filter results'

    argument :field, String, required: true
    # TODO: Maybe change the name of this 'values' argument because is a reserved name. Adding
    # `method_access: false` stops this from raising a warning, but it may be better to just rename.
    argument :values, [String], required: true #, method_access: false # need method_access param to silence errors
    argument :match_type, Enums::FilterMatchEnum, default_value: 'EQUALS', required: false
  end
end
