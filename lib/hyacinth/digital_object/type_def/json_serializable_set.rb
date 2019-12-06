# frozen_string_literal: true

# TODO: Delete if not used
module Hyacinth
  module DigitalObject
    module TypeDef
      class JsonSerializableSet < Hyacinth::DigitalObject::TypeDef::JsonSerializableCollection
        def from_serialized_form_impl(json_var)
          return nil if json_var.nil?
          raise ArgumentError, "Expected array, but got: #{json_var.class}" unless json_var.is_a?(Array)
          json_var = json_var.map { |value| @translator.from_serialized_form_impl(value) } if @translator
          json_var.to_set # parsed JSON value will come in as an Array, so we need to convert to a Set
        end

        def to_serialized_form_impl(json_var)
          return nil if json_var.nil?
          raise ArgumentError, "Expected set, but got: #{json_var.class}" unless json_var.is_a?(Set)
          json_var = json_var.map { |value| @translator.to_serialized_form_impl(value) } if @translator
          json_var.to_a # need to convert to an Array for serialization
        end
      end
    end
  end
end
