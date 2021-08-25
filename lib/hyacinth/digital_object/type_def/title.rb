# frozen_string_literal: true

module Hyacinth
  module DigitalObject
    module TypeDef
      class Title < Hyacinth::DigitalObject::TypeDef::JsonSerializableCollection
        FIELDS = %w[non_sort_portion sort_portion subtitle lang].freeze
        def to_serialized_form_impl(json_var)
          return nil if json_var.blank?
          json_var = json_var.dup
          raise ArgumentError, "Expected hash, but got: #{json_var.class}" unless json_var.is_a?(Hash)
          json_var = json_var.keep_if { |k, v| FIELDS.include?(k) && v&.strip.present? }
          return nil if json_var.blank?
          json_var['lang'] &&= TypeDef::Language.new.to_serialized_form_impl(json_var['lang'])
          json_var
        end

        def from_serialized_form_impl(json_var)
          return nil if json_var.nil?
          json_var = json_var.dup
          raise ArgumentError, "Expected hash, but got: #{json_var.class}" unless json_var.is_a?(Hash)
          json_var['lang'] &&= TypeDef::Language.new.from_serialized_form_impl(json_var['lang'])
          json_var
        end
      end
    end
  end
end
