# frozen_string_literal: true

module Types
  class DigitalObjectImportType < Types::BaseObject
    field :id, ID, null: false
    field :import_errors, [String], null: true
    field :index, Integer, null: true
    field :status, Enums::DigitalObjectImportStatusEnum, null: false
    field :digital_object_data, String, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
