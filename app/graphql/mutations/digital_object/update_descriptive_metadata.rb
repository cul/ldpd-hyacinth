# frozen_string_literal: true

module Mutations
  module DigitalObject
    class UpdateDescriptiveMetadata < Mutations::BaseMutation
      argument :id, ID, required: true
      argument :descriptive_metadata, GraphQL::Types::JSON, required: false
      argument :identifiers, [String], required: false
      argument :optimistic_lock_token, String, required: false

      field :digital_object, Types::DigitalObjectInterface, null: true
      field :user_errors, [Types::Errors::FieldedInput], null: false

      def resolve(id:, **attributes)
        digital_object = ::DigitalObject.find_by_uid!(id)
        ability.authorize! :update, digital_object
        digital_object.assign_attributes(attributes.stringify_keys)
        digital_object.updated_by = context[:current_user]

        if digital_object.save
          { digital_object: digital_object, user_errors: [] }
        else
          {
            digital_object: nil,
            user_errors: digital_object.errors.map { |key, message| { path: [key], message: message } }
          }
        end
      end
    end
  end
end
