# frozen_string_literal: true

module Mutations
  module DigitalObject
    class CreateDigitalObject < Mutations::BaseMutation
      argument :project, Inputs::StringKey, "String key for project", required: true
      argument :digital_object_type, Enums::DigitalObjectTypeEnum, "digital object type", required: true
      argument :descriptive_metadata, GraphQL::Types::JSON, required: true
      argument :identifiers, [String], required: true

      field :digital_object, Types::DigitalObjectInterface, null: true
      field :user_errors, [Types::Errors::FieldedInput], null: false

      def resolve(project:, digital_object_type:, descriptive_metadata:, identifiers:)
        project = Project.find_by!(project.to_h)
        ability.authorize! :create_objects, project

        digital_object = Hyacinth::Config.digital_object_types.key_to_class(digital_object_type).new
        digital_object.primary_project = project
        digital_object.assign_attributes(
          'identifiers' => identifiers, 'descriptive_metadata' => descriptive_metadata
        )
        digital_object.created_by = context[:current_user]
        digital_object.updated_by = context[:current_user]

        if digital_object.save
          { digital_object: digital_object, user_errors: [] }
        else
          { digital_object: nil, user_errors: digital_object.errors.map { |key, message| { path: [key], message: message } } }
        end
      end
    end
  end
end
