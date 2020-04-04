# frozen_string_literal: true

module Mutations
  module DigitalObject
    class UpdateRights < Mutations::BaseMutation
      argument :id, ID, required: true
      argument :rights, GraphQL::Types::JSON, required: true

      field :digital_object, Types::DigitalObjectInterface, null: false

      def resolve(id:, rights:)
        digital_object = ::DigitalObject::Base.find(id)

        ability.authorize! :update_rights, digital_object
        digital_object.assign_rights({ 'rights' => rights.stringify_keys }, false)
        digital_object.save!(update_index: true, user: context[:current_user])
        { digital_object: digital_object }
      end
    end
  end
end
