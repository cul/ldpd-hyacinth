# frozen_string_literal: true

module Mutations
  module DigitalObject
    class AddParent < Mutations::BaseMutation
      argument :id, ID, required: true
      argument :parent_id, ID, required: true

      field :digital_object, Types::DigitalObjectInterface, null: true

      def resolve(id:, parent_id:)
        digital_object = ::DigitalObject.find_by_uid!(id)
        parent_object = ::DigitalObject.find_by_uid!(parent_id)

        'You do not have permission to add the specified parent-child relationship'.tap do |permission_message|
          ability.authorize! :update, parent_object, message: permission_message
          ability.authorize! :read, digital_object, message: permission_message
        end

        digital_object.parents_to_add << parent_object

        if digital_object.save
          { digital_object: digital_object, user_errors: [] }
        else
          {
            digital_object: nil, user_errors: digital_object.errors.full_messages.map { |msg| { message: msg, path: [] } }
          }
        end
      end
    end
  end
end
