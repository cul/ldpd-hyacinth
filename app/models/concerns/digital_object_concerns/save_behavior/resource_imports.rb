module DigitalObjectConcerns
  module SaveBehavior
    module ResourceImports
      extend ActiveSupport::Concern

      def handle_resource_imports
        # Handle new imports
        self.resource_attributes.map do |resource_name, resource|
          # TODO: make sure to renew the lock in case checksum generation or file copying take a long time
          resource.process_import_if_present(self.uid, resource_name)
        end
      end
    end
  end
end
