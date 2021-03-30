# frozen_string_literal: true

module Hyacinth
  module DigitalObject
    module ResourceAttributes
      def self.included(base)
        base.extend ClassMethods
      end

      def resource_attributes
        self.class.send(__method__) # class method name same as instance method
      end

      def resource_import_attributes
        self.class.send(__method__) # class method name same as instance method
      end

      def resources
        @resources ||= resource_attributes.map { |key| [key.to_s, nil] }.to_h.with_indifferent_access
      end

      def resource_imports
        @resource_imports ||= resource_import_attributes.map { |key| [key.to_s, nil] }.to_h.with_indifferent_access
      end

      def old_resources
        @old_resources ||= resource_attributes.map { |key| [key.to_s, nil] }.to_h.with_indifferent_access
      end

      def deleted_resources
        @deleted_resources ||= resource_attributes.map { |key| [key.to_s, nil] }.to_h.with_indifferent_access
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

          # Add x_resource_name method (e.g. master_resource_name)
          define_method :"#{resource_attribute_name}_resource_name" do
            resource_attribute_name.to_s # cast to string because otherwise we'd return a symbol
          end

          # Add x_resource method (e.g. master_resource)
          define_method :"#{resource_attribute_name}_resource" do
            resources[resource_attribute_name]
          end

          # Add has_x_resource? method (e.g. has_master_resource?)
          define_method :"has_#{resource_attribute_name}_resource?" do
            resources[resource_attribute_name].present?
          end
        end
      end
    end
  end
end
