# frozen_string_literal: true

module Types
  class ResourceRequestType < Types::BaseObject
    description 'A resource request'

    field :id, ID, null: false
    field :digital_object_uid, String, null: false
    field :job_type, String, null: false
    field :status, String, null: false
    field :src_file_location, String, null: false
    field :options, GraphQL::Types::JSON, null: true
    field :processing_errors, [String], null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: true
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: true
  end
end
