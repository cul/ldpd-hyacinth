# frozen_string_literal: true

module Mutations
  module DigitalObject
    class UpdateFeaturedThumbnailRegion < Mutations::BaseMutation
      argument :id, ID, required: true
      argument :featured_thumbnail_region, String, required: true

      field :digital_object, Types::DigitalObjectInterface, null: false
      field :user_errors, [Types::Errors::FieldedInput], null: false

      def resolve(id:, featured_thumbnail_region:)
        digital_object = ::DigitalObject.find_by_uid!(id)
        ability.authorize! :update, digital_object

        raise_error_if_unsupported_object_type!(digital_object)

        digital_object.featured_thumbnail_region = featured_thumbnail_region
        digital_object.updated_by = context[:current_user]

        if digital_object.save
          { digital_object: digital_object, user_errors: [] }
        else
          {
            digital_object: digital_object,
            user_errors: digital_object.errors.full_messages.map { |msg| { message: msg, path: [] } }
          }
        end
      end

      def raise_error_if_unsupported_object_type!(digital_object)
        return if digital_object.respond_to?(:featured_thumbnail_region)
        raise GraphQL::ExecutionError, "#{digital_object.digital_object_type.capitalize.pluralize} do not have a featured thumbnail region."
      end
    end
  end
end
