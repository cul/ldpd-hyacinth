# frozen_string_literal: true

module Mutations
  module DigitalObject
    module Resource
      class CreateResource < Mutations::BaseMutation
        argument :id, ID, required: true
        argument :resource_name, String, required: true
        argument :file_location, String, required: true

        field :digital_object, Types::DigitalObjectInterface, null: true
        field :user_errors, [Types::Errors::FieldedInput], null: false

        def resolve(id:, resource_name:, file_location:)
          digital_object = ::DigitalObject::Base.find(id)
          ability.authorize! :update, digital_object

          # At this time, non-admins can only perform blob-based asset creation
          raise GraphQL::ExecutionError, 'You are only authorized to create resources from ActiveStorage blob uploads.' unless file_location.start_with?('blob://') || ability.can?(:manage, :all)

          raise_error_if_invalid_resource!(digital_object, resource_name)

          # An existing resource should be explicitly deleted before replacing it with a new one.
          raise_error_if_resource_exists!(digital_object, resource_name)

          # Create a new resource import, which will be processed when the object is saved
          digital_object.resource_imports[resource_name] = Hyacinth::DigitalObject::ResourceImport.new(method: Hyacinth::DigitalObject::ResourceImport::COPY, location: file_location)

          # Save the object
          if digital_object.save!(update_index: true, user: context[:current_user])
            { digital_object: digital_object, user_errors: [] }
          else
            { digital_object: digital_object, user_errors: digital_object.errors.full_messages.map { |msg| { message: msg, path: [] } } }
          end
        ensure
          # If the file_location was an ActiveStorage blob, make sure to delete it now that we're done with it.
          ActiveStorage::Blob.find_signed(file_location.sub('blob://', ''))&.purge if file_location.start_with?('blob://')
        end

        private

          def raise_error_if_invalid_resource!(digital_object, resource_name)
            return if digital_object.resource_attributes.include?(resource_name.to_sym)
            raise GraphQL::ExecutionError, %(Resource type "#{resource_name}" is not valid for #{digital_object.digital_object_type.pluralize})
          end

          def raise_error_if_resource_exists!(digital_object, resource_name)
            return if digital_object.resources[resource_name].blank?
            raise GraphQL::ExecutionError,
                  %(This #{digital_object.digital_object_type} already has a resource with name "#{resource_name}". ) +
                  %(If you want to replace the current "#{resource_name}" resource, delete it and then create a new one.)
          end
      end
    end
  end
end
