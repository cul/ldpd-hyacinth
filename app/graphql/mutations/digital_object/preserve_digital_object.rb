# frozen_string_literal: true

module Mutations
  module DigitalObject
    class PreserveDigitalObject < Mutations::BaseMutation
      argument :id, ID, required: true

      field :digital_object, Types::DigitalObjectInterface, null: false
      field :user_errors, [Types::Errors::FieldedInput], null: false

      def resolve(id:)
        digital_object = ::DigitalObject.find_by_uid!(id)
        ability.authorize! :preserve, digital_object

        if digital_object.preserve
          { digital_object: digital_object, user_errors: [] }
        else
          {
            digital_object: digital_object,
            user_errors: digital_object.errors.full_messages.map { |msg| { message: msg, path: [] } }
          }
        end
      end
    end
  end
end
