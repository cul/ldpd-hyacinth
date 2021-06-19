# frozen_string_literal: true

module Mutations
  module DigitalObject
    class DeleteDigitalObject < Mutations::BaseMutation
      argument :id, ID, required: true

      field :digital_object, Types::DigitalObjectInterface, null: true

      # TODO: Consider removing this mutation in favor of one that just changes the state
      def resolve(id:)
        digital_object = ::DigitalObject.find_by_uid!(id)
        ability.authorize! :delete, digital_object
        digital_object.state = 'deleted'
        digital_object.updated_by = context[:current_user]
        digital_object.updated_at = DateTime.current
        digital_object.save!

        { digital_object: digital_object }
      end
    end
  end
end
