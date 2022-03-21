# frozen_string_literal: true

module Mutations
  module DigitalObject
    class UpdateRights < Mutations::BaseMutation
      argument :id, ID, required: true
      argument :rights, GraphQL::Types::JSON, required: true
      argument :optimistic_lock_token, String, required: false

      field :digital_object, Types::DigitalObjectInterface, null: true
      field :user_errors, [Types::Errors::FieldedInput], null: false

      def resolve(id:, **attributes)
        digital_object = ::DigitalObject.find_by_uid!(id)
        ability.authorize! :update_rights, digital_object
        digital_object.assign_attributes(attributes.stringify_keys, true, false)
        digital_object.updated_by = context[:current_user]

        if digital_object.save
          { digital_object: digital_object, user_errors: [] }
        else
          {
            digital_object: nil,
            user_errors: digital_object.errors.map { |error| { path: [error.attribute], message: error.message } }
          }
        end
      end
    end
  end
end
