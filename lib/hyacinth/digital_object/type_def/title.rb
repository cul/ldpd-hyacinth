# frozen_string_literal: true

module Hyacinth
  module DigitalObject
    module TypeDef
      class Title < Hyacinth::DigitalObject::TypeDef::JsonSerializableCollection
        FIELDS = %w[value subtitle value_lang].freeze
        def to_serialized_form_impl(json_var)
          return nil if json_var.blank?
          json_var = json_var.dup
          raise ArgumentError, "Expected hash, but got: #{json_var.class}" unless json_var.is_a?(Hash)
          json_var['subtitle'] = json_var['subtitle']&.strip
          json_var['value'] &&= TypeDef::Title::Value.new.to_serialized_form_impl(json_var['value'])
          json_var['value_lang'] &&= TypeDef::Language.new.to_serialized_form_impl(json_var['value_lang'])
          json_var.keep_if { |k, v| FIELDS.include?(k) && v.present? }
          return nil if json_var.blank?
          json_var
        end

        def from_serialized_form_impl(json_var)
          return nil if json_var.nil?
          json_var = json_var.dup
          raise ArgumentError, "Expected hash, but got: #{json_var.class}" unless json_var.is_a?(Hash)
          json_var['value'] &&= TypeDef::Title::Value.new.from_serialized_form_impl(json_var['value'])
          json_var['value_lang'] &&= TypeDef::Language.new.from_serialized_form_impl(json_var['value_lang'])
          json_var
        end

        def valid?(json_var)
          super && valid_keys?(json_var) && valid_value?(json_var) && valid_language?(json_var)
        end

        def valid_keys?(json_var)
          json_var.blank? || (json_var.keys - FIELDS).blank?
        end

        def valid_value?(json_var)
          json_var.blank? || TypeDef::Title::Value.new.valid?(json_var['value'])
        end

        def valid_language?(json_var)
          json_var.blank? || TypeDef::Language.new.valid?(json_var['value_lang'])
        end

        class Value < Hyacinth::DigitalObject::TypeDef::JsonSerializableCollection
          FIELDS = %w[non_sort_portion sort_portion].freeze
          def to_serialized_form_impl(json_var)
            return nil if json_var.blank?
            json_var = json_var.dup
            raise ArgumentError, "Expected hash, but got: #{json_var.class}" unless json_var.is_a?(Hash)
            json_var = json_var.keep_if { |k, v| FIELDS.include?(k) && v&.strip.present? }
            return nil if json_var.blank?
            json_var
          end

          def from_serialized_form_impl(json_var)
            return nil if json_var.blank?
            raise ArgumentError, "Expected hash, but got: #{json_var.class}" unless json_var.is_a?(Hash)
            json_var
          end

          def valid?(json_var)
            json_var.blank? || (json_var.keys - FIELDS).blank?
          end
        end
      end
    end
  end
end
