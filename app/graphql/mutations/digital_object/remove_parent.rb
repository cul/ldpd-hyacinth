# frozen_string_literal: true

module Mutations
  module DigitalObject
    class RemoveParent < Mutations::BaseMutation
      argument :id, ID, required: true
      argument :parent_id, ID, required: true

      field :digital_object, Types::DigitalObjectInterface, null: true

      def resolve(id:, parent_id:)
        digital_object = ::DigitalObject.find_by_uid!(id)
        parent_object = ::DigitalObject.find_by_uid!(parent_id)
        ability.authorize! :update, parent_object, :read, digital_object, :message, "Not authorized to remove parent object"
        digital_object.parents_to_remove << parent_object
        if digital_object.save
          { digital_object: digital_object, user_errors: [] }
        else
          {
            digital_object: nil,
            user_errors: digital_object.errors.full_messages.map { |msg| { message: msg, path: [] } }
          }
        end
      end
    end
  end
end
