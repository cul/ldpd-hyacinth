# frozen_string_literal: true

module Types
  class ExportJobType < Types::BaseObject
    description 'An export job'

    field :id, ID, null: false
    field :search_params, String, null: false
    field :file_location, String, null: false
    field :user, UserType, null: true
    field :export_errors, [String], null: true
    field :status, Enums::ExportJobStatusEnum, null: false
    field :duration, Integer, null: false
    field :number_of_records_processed, Integer, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
