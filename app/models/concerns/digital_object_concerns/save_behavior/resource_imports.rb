# frozen_string_literal: true

module DigitalObjectConcerns
  module SaveBehavior
    module ResourceImports
      extend ActiveSupport::Concern

      # @param lock_object [LockObject] A lock object can be optionally passed in
      # so that an external lock can be extended while the resource import occurs.
      # Imports can take a long time, so an externally-established lock may
      # expire if not renewed within a resource import.
      def handle_resource_imports(lock_object)
        # Handle new imports
        self.resource_attributes.each do |resource_name|
          # TODO: make sure to renew the lock in case checksum generation or file copying take a long time
          resource = resources[resource_name]
          resource.process_import_if_present(self.uid, resource_name, lock_object)
        end
      end

      def clear_resource_import_data
        self.resource_attributes.each do |resource_name|
          resource = resources[resource_name]
          resource.clear_import_data
        end
      end
    end
  end
end
