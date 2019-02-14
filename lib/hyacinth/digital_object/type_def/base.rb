module Hyacinth
  module DigitalObject
    module TypeDef
      class Base
        attr_reader :allowed_class_types, :allowed_values

        def initialize(allowed_class_types)
          raise NotImplementedError, "Cannot instantiate #{self.class}. Instantiate a subclass instead." if self.class == Hyacinth::DigitalObject::TypeDef::Base
          @allowed_class_types = (allowed_class_types.is_a?(Array) ? allowed_class_types : [allowed_class_types]).freeze
          @default_value_proc = -> { nil }
          @public_writer = false
          @allowed_values = []
        end

        # digital object data serialization and deserialization

        def attribute_to_digital_object_data(value)
          raise NotImplementedError # this implementation must be overridden by subclasses
        end

        def digital_object_data_to_attribute(value)
          raise NotImplementedError # this implementation must be overridden by subclasses
        end

        ### Setters, meant to be chained. e.g. Hyacinth::TypeDef.new(String, nil).public_writer.optional

        def public_writer
          @public_writer = true
          self # always return self to allow for chained calls
        end

        def allow(values)
          @allowed_values = values
          self # always return self to allow for chained calls
        end

        def default(default_value_proc)
          raise ArgumentError, 'Invalid default value. Must provide a Proc.' unless default_value_proc.is_a?(Proc)
          @default_value_proc = default_value_proc
          self # always return self to allow for chained calls
        end

        ### Getters

        def default_value
          @default_value_proc.call
        end

        def public_writer?
          @public_writer
        end
      end
    end
  end
end
