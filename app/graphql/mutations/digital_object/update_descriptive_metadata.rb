# frozen_string_literal: true

module Mutations
  module DigitalObject
    class UpdateDescriptiveMetadata < Mutations::BaseMutation
      argument :id, ID, required: true
      argument :descriptive_metadata, GraphQL::Types::JSON, required: true
      argument :identifiers, [String], required: true

      field :digital_object, Types::DigitalObjectInterface, null: false
      field :errors, [Types::Errors::FieldedInput], null: false

      def resolve(id:, descriptive_metadata:, identifiers:)
        digital_object = ::DigitalObject::Base.find(id)
        ability.authorize! :update, digital_object
        digital_object.assign_attributes(
          'identifiers' => identifiers,
          'descriptive_metadata' => descriptive_metadata
        )
        if digital_object.save(update_index: true, user: context[:current_user])
          { digital_object: digital_object, errors: [] }
        else
          {
            digital_object: digital_object,
            errors: digital_object.errors.full_messages.map { |msg| { message: msg, path: [] } }
          }
        end
      end
    end
  end
end
