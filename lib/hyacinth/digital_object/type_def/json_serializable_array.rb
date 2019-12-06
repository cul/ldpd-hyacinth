# frozen_string_literal: true

module Hyacinth
  module DigitalObject
    module TypeDef
      class JsonSerializableArray < Hyacinth::DigitalObject::TypeDef::JsonSerializableCollection
        def from_serialized_form_impl(json_var)
          return nil if json_var.nil?
          raise ArgumentError, "Expected array, but got: #{json_var.class}" unless json_var.is_a?(Array)
          json_var = json_var.map { |value| @translator.from_serialized_form_impl(value) } if @translator
          json_var
        end

        def to_serialized_form_impl(json_var)
          return nil if json_var.nil?
          raise ArgumentError, "Expected array, but got: #{json_var.class}" unless json_var.is_a?(Array)
          json_var = json_var.map { |value| @translator.to_serialized_form_impl(value) } if @translator
          json_var
        end
      end
    end
  end
end
