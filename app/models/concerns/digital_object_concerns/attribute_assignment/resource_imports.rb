# frozen_string_literal: true

module DigitalObjectConcerns
  module AttributeAssignment
    module ResourceImports
      extend ActiveSupport::Concern

      def assign_resource_imports(digital_object_data)
        return unless digital_object_data.key?('resource_imports')

        digital_object_data['resource_imports'].each do |resource_key, resource_import_data|
          self.resource_imports[resource_key] = Hyacinth::DigitalObject::ResourceImport.new(resource_import_data)
        end
      end
    end
  end
end
