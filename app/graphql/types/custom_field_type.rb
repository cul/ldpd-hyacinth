# frozen_string_literal: true

module Types
  class CustomFieldType < Types::BaseObject
    description 'A custom field value'

    field :field, String, null: false
    field :value, Types::Scalar::AnyPrimitiveType, null: true
  end
end
