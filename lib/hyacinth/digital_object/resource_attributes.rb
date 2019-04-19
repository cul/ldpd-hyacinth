module Hyacinth
  module DigitalObject
    module ResourceAttributes

      def self.included(base)
        base.extend ClassMethods
      end

      def resource_attributes
        self.class.resource_attributes
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

        def resource_attribute(resource_attribute_name)
          @resource_attributes ||= Set.new
          @resource_attributes << resource_attribute_name.to_sym

          # always create a reader method
          define_method(resource_attribute_name) do
            instance_variable_set("@#{resource_attribute_name}", Hyacinth::DigitalObject::Resource.new) unless instance_variable_defined?("@#{resource_attribute_name}")
            instance_variable_get("@#{resource_attribute_name}")
          end

          # create a private writer method
          writer_method_name = "#{resource_attribute_name}="
          define_method(writer_method_name) do |value|
            instance_variable_set("@#{resource_attribute_name}", value)
          end

          # make writer method private
          private writer_method_name.to_sym
        end
      end
    end
  end
end
