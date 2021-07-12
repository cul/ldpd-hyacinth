# frozen_string_literal: true

module Mutations
  module DigitalObject
    class PurgeDigitalObject < Mutations::BaseMutation
      argument :id, ID, required: true

      field :digital_object, Types::DigitalObjectInterface, null: true

      # TODO: Consider renaming this mutation to DeleteDigitalObject if the DeleteDigitalObject is replaced by an UpdateDigitalObjectState mutation
      def resolve(id:)
        digital_object = ::DigitalObject.find_by_uid!(id)
        ability.authorize! :purge, digital_object
        digital_object.destroy!

        { digital_object: digital_object }
      end
    end
  end
end
