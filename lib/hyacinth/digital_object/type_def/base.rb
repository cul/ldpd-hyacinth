module Hyacinth
  module DigitalObject
    module TypeDef
      class Base
        def initialize
          raise NotImplementedError,
            "Cannot instantiate #{self.class}. Instantiate a subclass instead." if self.class == Base
          @default_value_proc = -> { nil }
          @public_writer = false
        end

        # digital object data serialization and deserialization

        def to_json_var(value)
          raise NotImplementedError # this implementation must be overridden by subclasses
        end

        def from_json_var(value)
          raise NotImplementedError # this implementation must be overridden by subclasses
        end

        ### Setters, meant to be chained. e.g. Hyacinth::TypeDef.new(String, nil).public_writer.optional

        def public_writer
          @public_writer = true
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
