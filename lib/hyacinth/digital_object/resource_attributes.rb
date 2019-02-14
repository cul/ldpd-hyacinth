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
          @resource_attributes ||= {} # initialized here because it may not have been initialized in a subclass of the including class
          if self.superclass.respond_to?(:resource_attributes)
            @resource_attributes.merge(self.superclass.resource_attributes)
          else
            @resource_attributes
          end
        end

        def resource_attribute(resource_attribute_name)
          @resource_attributes ||= {}
          @resource_attributes[resource_attribute_name.to_sym] = Hyacinth::DigitalObject::Resource.new
        end
      end
    end
  end
end
