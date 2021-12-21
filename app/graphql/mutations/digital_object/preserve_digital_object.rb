# frozen_string_literal: true

module Mutations
  module DigitalObject
    class PreserveDigitalObject < Mutations::BaseMutation
      argument :id, ID, required: true

      field :digital_object, Types::DigitalObjectInterface, null: true
      field :user_errors, [Types::Errors::FieldedInput], null: true

      def resolve(id:)
        digital_object = ::DigitalObject.find_by_uid!(id)
        ability.authorize! :preserve, digital_object

        if digital_object.preserve
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
