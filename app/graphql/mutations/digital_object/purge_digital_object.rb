# frozen_string_literal: true

module Mutations
  module DigitalObject
    class PurgeDigitalObject < Mutations::BaseMutation
      argument :id, ID, required: true

      field :digital_object, Types::DigitalObjectInterface, null: true

      def resolve(id:)
        digital_object = ::DigitalObject::Base.find(id)

        ability.authorize! :purge, digital_object

        digital_object.purge!

        { digital_object: digital_object }
      end
    end
  end
end
