# frozen_string_literal: true

module Types
  class FilterAttributes < Types::BaseInputObject
    description 'A field/value pair that can be used to filter results'

    argument :field, String, required: true
    argument :value, String, required: true
  end
end
