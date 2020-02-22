# frozen_string_literal: true

module Types
  class BatchExportType < Types::BaseObject
    include Types::Pageable

    description 'An batch export'

    field :id, ID, null: false
    field :search_params, String, null: false
    field :file_location, String, null: false
    field :user, UserType, null: true
    field :errors, [String], null: true
    field :status, Enums::BatchExportStatusEnum, null: false
    field :duration, Integer, null: false
    field :number_of_records_processed, Integer, null: false
    field :total_records_to_process, Integer, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
