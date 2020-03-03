# frozen_string_literal: true

module Types
  class BatchImportType < Types::BaseObject
    description 'A batch import'

    field :id, ID, null: false
    field :file_location, String, null: true
    field :user, UserType, null: true
    field :priority, Enums::BatchImportPriorityEnum, null: true
    field :status, Enums::BatchImportStatusEnum, null: false
    field :cancelled, Boolean, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    # Retrieve counts for each status of digital object imports.
    DigitalObjectImport.statuses.each do |status, _number|
      field "number_of_#{status}_imports", Integer, null: false, resolver_method: "#{status}_count"

      define_method "#{status}_count" do
        object.import_count(status)
      end
    end

    field :digital_object_imports, DigitalObjectImportType.results_type, extensions: [Types::Extensions::Paginate], null: true do
      argument :status, Enums::DigitalObjectImportStatusEnum, required: false
      description "Results for digital object import ordered by ascending index"
    end

    field :digital_object_import, DigitalObjectImportType, null: true do
      argument :id, ID, required: true
    end

    def digital_object_imports(status: nil)
      if status
        object.digital_object_imports.where(status: status).order(:index)
      else
        object.digital_object_imports.order(:index)
      end
    end

    def digital_object_import(id:)
      object.digital_object_imports.find(id)
    end
  end
end
