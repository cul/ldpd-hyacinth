# frozen_string_literal: true

module Mutations
  module DigitalObject
    module Resource
      class DeleteResource < Mutations::BaseMutation
        argument :id, ID, required: true
        argument :resource_name, String, required: true

        field :digital_object, Types::DigitalObjectInterface, null: true
        field :user_errors, [Types::Errors::FieldedInput], null: false

        def resolve(id:, resource_name:)
          digital_object = ::DigitalObject.find_by_uid!(id)
          ability.authorize! :update, digital_object

          raise_error_if_asset_master_resource!(digital_object, resource_name)
          raise_error_if_invalid_resource!(digital_object, resource_name)
          raise_error_if_resource_not_found!(digital_object, resource_name)
          digital_object.delete_resource(resource_name)

          # When a resource is deleted on an Asset (often because a user wants to upload their own
          # new version), we do not want Hyacinth to automatically queue regeneration.
          digital_object.skip_resource_request_callbacks = true if digital_object.is_a?(::DigitalObject::Asset)
          digital_object.updated_by = context[:current_user]

          # Save the object
          if digital_object.save
            { digital_object: digital_object, user_errors: [] }
          else
            {
              digital_object: nil,
              user_errors: digital_object.errors.full_messages.map { |msg| { message: msg, path: [] } }
            }
          end
        end

        private

          def raise_error_if_invalid_resource!(digital_object, resource_name)
            return if digital_object.resource_attributes.include?(resource_name.to_sym)
            raise GraphQL::ExecutionError, %(Resource type "#{resource_name}" is not valid for #{digital_object.digital_object_type.pluralize})
          end

          def raise_error_if_resource_not_found!(digital_object, resource_name)
            return if digital_object.resources[resource_name].present?
            raise GraphQL::ExecutionError, %(No "#{resource_name}" resource found for this #{digital_object.digital_object_type})
          end

          def raise_error_if_asset_master_resource!(digital_object, resource_name)
            return unless digital_object.is_a?(::DigitalObject::Asset)
            return unless resource_name == digital_object.master_resource_name
            raise GraphQL::ExecutionError, "Cannot delete the #{resource_name} resource for an #{digital_object.digital_object_type}. Create a new #{digital_object.digital_object_type} instead."
          end
      end
    end
  end
end
