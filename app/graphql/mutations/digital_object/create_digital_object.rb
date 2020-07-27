# frozen_string_literal: true

module Mutations
  module DigitalObject
    class CreateDigitalObject < Mutations::BaseMutation
      argument :project, Inputs::Project::StringKey, "String key for project", required: true
      argument :digital_object_type, Enums::DigitalObjectTypeEnum, "digital object type", required: true
      argument :descriptive_metadata, GraphQL::Types::JSON, required: true
      argument :identifiers, [String], required: true

      field :digital_object, Types::DigitalObjectInterface, null: false
      field :errors, [Types::Errors::FieldedInput], null: false

      def resolve(project:, digital_object_type:, descriptive_metadata:, identifiers:)
        project = Project.find_by!(project.to_h)
        ability.authorize! :create_objects, project

        digital_object = Hyacinth::Config.digital_object_types.key_to_class(digital_object_type).new
        digital_object.primary_project = project
        digital_object.assign_attributes(
          'identifiers' => Set.new(identifiers), 'descriptive_metadata' => descriptive_metadata
        )
        if digital_object.save(update_index: true, user: context[:current_user])
          { digital_object: digital_object, errors: [] }
        else
          { digital_object: { id: 'new' }, errors: digital_object.errors.full_messages.map { |msg| { message: msg, path: [] } } }
        end
      end
    end
  end
end
