# frozen_string_literal: true

module Types
  class CustomFieldAttributes < Types::BaseInputObject
    description 'A custom field field/value pair'

    argument :field, String, required: true
    argument :value, Types::Scalar::AnyPrimitiveType, required: false
  end
end
