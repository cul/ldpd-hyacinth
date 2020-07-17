# frozen_string_literal: true

module Types
  class EnabledDynamicFieldType < Types::BaseObject
    description 'An enabled dynamic field in a project'

    field :id, ID, null: false
    field :dynamic_field, DynamicFieldType, null: false
    field :field_sets, [FieldSetType], null: false
    field :project, ProjectType, null: false
    field :digital_object_type, Enums::DigitalObjectTypeEnum, null: false
    field :required, Boolean, null: false
    field :locked, Boolean, null: false
    field :hidden, Boolean, null: false
    field :owner_only, Boolean, null: false
    field :shareable, Boolean, null: false

    field :default_value, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: true
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: true
  end
end
