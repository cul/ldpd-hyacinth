# frozen_string_literal: true

module Hyacinth
  module DigitalObject
    module MetadataAttributes
      def self.included(base)
        base.extend ClassMethods
      end

      def metadata_attributes
        self.class.metadata_attributes
      end

      module ClassMethods
        def metadata_attributes
          # We initialize @metadata_attributes here because it may not have been
          # initialized in a subclass of the including class.
          @metadata_attributes ||= {}
          if self.superclass.respond_to?(:metadata_attributes)
            @metadata_attributes.merge(self.superclass.metadata_attributes)
          else
            @metadata_attributes
          end
        end

        def metadata_attribute(metadata_attribute_name, type_def)
          @metadata_attributes ||= {}
          @metadata_attributes[metadata_attribute_name.to_sym] = type_def

          # always create a reader method
          define_method(metadata_attribute_name) do
            unless instance_variable_defined?("@#{metadata_attribute_name}")
              instance_variable_set("@#{metadata_attribute_name}", type_def.default_value)
            end
            instance_variable_get("@#{metadata_attribute_name}")
          end

          # Create a writer method, which may or may not be public.
          writer_method_name = "#{metadata_attribute_name}="
          define_method(writer_method_name) do |value|
            instance_variable_set("@#{metadata_attribute_name}", value)
          end

          # Make writer method private by default, unless requested as public.
          private writer_method_name.to_sym unless type_def.public_writer?
        end
      end
    end
  end
end
