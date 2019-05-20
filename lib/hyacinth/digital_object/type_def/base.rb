module Hyacinth
  module DigitalObject
    module TypeDef
      class Base
        def initialize
          raise NotImplementedError,
            "Cannot instantiate #{self.class}. Instantiate a subclass instead." if self.class == Base
          @default_value_proc = -> { nil }
          @public_writer = false
          @freeze_on_deserialize = false
        end

        # digital object data serialization and deserialization

        def to_serialized_form(value)
          to_serialized_form_impl(value)
        end

        def to_serialized_form_impl(value)
          raise NotImplementedError # this implementation must be overridden by subclasses
        end

        def from_serialized_form(json_var)
          value = from_serialized_form_impl(json_var)
          value.freeze if self.freeze_on_deserialize?
          value
        end

        def from_serialized_form_impl
          raise NotImplementedError # this implementation must be overridden by subclasses
        end

        ### Setters, meant to be chained. e.g. Hyacinth::TypeDef.new(String, nil).public_writer.optional

        def public_writer
          @public_writer = true
          self # always return self to allow for chained calls
        end

        # Constraint is checked by call to include?, so a values hash is verifying by key presence
        def constrained_to(values = [])
          @constrained = true
          @constrained_values = values
          self # always return self to allow for chained calls
        end

        def default(default_value_proc)
          raise ArgumentError, 'Invalid default value. Must provide a Proc.' unless default_value_proc.is_a?(Proc)
          @default_value_proc = default_value_proc
          self # always return self to allow for chained calls
        end

        def freeze_on_deserialize
          @freeze_on_deserialize = true
          self # always return self to allow for chained calls
        end

        ### Getters

        def default_value
          @default_value_proc.call
        end

        def public_writer?
          @public_writer
        end

        def constrained?
          @constrained
        end

        def valid_value?(value)
          return true unless @constrained
          @constrained_values.include?(value)
        end

        def freeze_on_deserialize?
          @freeze_on_deserialize
        end
      end
    end
  end
end
