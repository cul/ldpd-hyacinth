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
        digital_object.assign_attributes(attributes.stringify_keys, merge_descriptive_metadata: true, merge_rights: false)
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
