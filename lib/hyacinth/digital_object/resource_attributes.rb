# frozen_string_literal: true

module Hyacinth
  module DigitalObject
    module ResourceAttributes
      def self.included(base)
        base.extend ClassMethods
      end

      def resource_attributes
        self.class.resource_attributes
      end

      def resource_import_attributes
        self.class.resource_attributes
      end

      def resources
        @resources ||= resource_attributes.map { |key| [key.to_s, nil] }.to_h.with_indifferent_access
      end

      def resource_imports
        @resource_imports ||= resource_import_attributes.map { |key| [key.to_s, nil] }.to_h.with_indifferent_access
      end

      module ClassMethods
        def resource_attributes
          @resource_attributes ||= Set.new # initialized here because it may not have been initialized in a subclass of the including class
          if self.superclass.respond_to?(:resource_attributes)
            @resource_attributes.merge(self.superclass.resource_attributes)
          else
            @resource_attributes
          end
        end

        def resource_import_attributes
          @resource_import_attributes ||= Set.new # initialized here because it may not have been initialized in a subclass of the including class
          if self.superclass.respond_to?(:resource_import_attributes)
            @resource_import_attributes.merge(self.superclass.resource_import_attributes)
          else
            @resource_import_attributes
          end
        end

        def resource_attribute(resource_attribute_name)
          @resource_attributes ||= Set.new
          @resource_attributes << resource_attribute_name.to_sym

          @resource_import_attributes ||= Set.new
          @resource_import_attributes << resource_attribute_name.to_sym
        end
      end
    end
  end
end
