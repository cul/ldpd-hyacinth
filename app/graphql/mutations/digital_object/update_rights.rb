# frozen_string_literal: true

module Mutations
  module DigitalObject
    class UpdateRights < Mutations::BaseMutation
      argument :id, ID, required: true
      argument :rights, GraphQL::Types::JSON, required: true
      argument :optimistic_lock_token, String, required: true

      field :digital_object, Types::DigitalObjectInterface, null: false
      field :errors, [Types::Errors::FieldedInput], null: false

      def resolve(id:, rights:, optimistic_lock_token:)
        digital_object = ::DigitalObject::Base.find(id)
        ability.authorize! :update_rights, digital_object
        digital_object.assign_attributes(
          { 'rights' => rights.stringify_keys, 'optimistic_lock_token' => optimistic_lock_token },
          merge_descriptive_metadata: true, merge_rights: false
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
