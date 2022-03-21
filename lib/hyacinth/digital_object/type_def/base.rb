# frozen_string_literal: true

module Hyacinth
  module DigitalObject
    module TypeDef
      class Base
        def initialize
          raise NotImplementedError, "Cannot instantiate #{self.class}. Instantiate a subclass instead." if self.class == Base
          @default_value_proc = -> { nil }
          @private_writer = false
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

        ### Setters, meant to be chained. e.g. Hyacinth::TypeDef.new(String, nil).private_writer.optional

        def private_writer
          @private_writer = true
          self # always return self to allow for chained calls
        end

        def default(default_value_proc)
          raise ArgumentError, 'Invalid default value. Must provide a Proc.' unless default_value_proc.is_a?(Proc)
          @default_value_proc = default_value_proc
          self # always return self to allow for chained calls
        end

        def validation(valid_value_proc)
          raise ArgumentError, 'Invalid validation value. Must provide a Proc.' unless valid_value_proc.is_a?(Proc)
          @valid_value_proc = valid_value_proc
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

        def private_writer?
          @private_writer
        end

        def public_writer?
          !private_writer?
        end

        def valid?(value)
          return true unless @valid_value_proc
          @valid_value_proc.call(value)
        end

        def freeze_on_deserialize?
          @freeze_on_deserialize
        end
      end
    end
  end
end
