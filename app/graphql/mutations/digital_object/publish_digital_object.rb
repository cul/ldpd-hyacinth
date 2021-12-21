# frozen_string_literal: true

module Mutations
  module DigitalObject
    class PublishDigitalObject < Mutations::BaseMutation
      argument :id, ID, required: true
      argument :publish_to, [String], required: false
      argument :unpublish_from, [String], required: false

      field :digital_object, Types::DigitalObjectInterface, null: true
      field :user_errors, [Types::Errors::FieldedInput], null: true

      def resolve(id:, publish_to: [], unpublish_from: [])
        digital_object = ::DigitalObject.find_by_uid!(id)
        ability.authorize! :publish, digital_object

        # Remember: A publish/unpublish operation does NOT include the separate preserve operation!
        if digital_object.perform_publish_changes(publish_to: publish_targets_for(publish_to), unpublish_from: publish_targets_for(unpublish_from), publishing_user: context[:current_user])
          { digital_object: digital_object, user_errors: [] }
        else
          {
            digital_object: nil,
            user_errors: digital_object.errors.map { |error| { path: [error.attribute], message: error.message } }
          }
        end
      end

      def publish_targets_for(string_keys)
        PublishTarget.where(string_key: string_keys).to_a
      end
    end
  end
end
