# frozen_string_literal: true

module Mutations
  module DigitalObject
    class CreateDigitalObject < Mutations::BaseMutation
      argument :title, Inputs::DigitalObject::TitleInput, required: false
      argument :project, Inputs::StringKey, "String key for project", required: true
      argument :digital_object_type, Enums::DigitalObjectTypeEnum, "digital object type", required: true
      argument :descriptive_metadata, GraphQL::Types::JSON, required: true
      argument :identifiers, [String], required: false

      field :digital_object, Types::DigitalObjectInterface, null: true
      field :user_errors, [Types::Errors::FieldedInput], null: false

      def resolve(project:, digital_object_type:, descriptive_metadata:, title: nil, identifiers: nil)
        project = Project.find_by!(project.to_h)
        ability.authorize! :create_objects, project

        digital_object = Hyacinth::Config.digital_object_types.key_to_class(digital_object_type).new
        digital_object.primary_project = project

        assign_attributes(digital_object, descriptive_metadata, title, identifiers)
        digital_object.created_by = context[:current_user]
        digital_object.updated_by = context[:current_user]

        if digital_object.save
          { digital_object: digital_object, user_errors: [] }
        else
          { digital_object: nil, user_errors: digital_object.errors.map { |error| { path: [error.attribute], message: error.message } } }
        end
      end

      def assign_attributes(digital_object, descriptive_metadata, title, identifiers)
        attrs = { 'descriptive_metadata' => descriptive_metadata }
        attrs['title'] = title.to_h if title.present?
        attrs['identifiers'] = identifiers if identifiers.present?

        digital_object.assign_attributes(attrs)
      end
    end
  end
end
