# frozen_string_literal: true

# TODO: Delete if not used
module Hyacinth
  module DigitalObject
    module TypeDef
      class JsonSerializableHash < Hyacinth::DigitalObject::TypeDef::JsonSerializableCollection
        def from_serialized_form_impl(json_var)
          return nil if json_var.nil?
          raise ArgumentError, "Expected hash, but got: #{json_var.class}" unless json_var.is_a?(Hash)
          json_var = json_var.transform_values { |value| @translator.from_serialized_form_impl(value) } if @translator
          json_var
        end

        def to_serialized_form_impl(json_var)
          return nil if json_var.nil?
          raise ArgumentError, "Expected hash, but got: #{json_var.class}" unless json_var.is_a?(Hash)
          json_var = json_var.transform_values { |value| @translator.to_serialized_form_impl(value) } if @translator
          json_var
        end
      end
    end
  end
end
