# frozen_string_literal: true

module Hyacinth
  module DigitalObject
    module TypeDef
      class Language < Hyacinth::DigitalObject::TypeDef::Base
        def to_serialized_form_impl(json_var)
          return nil if json_var.nil?
          raise ArgumentError, "Expected hash, but got: #{json_var.class}" unless json_var.is_a?(Hash)
          # stores validated and preferred value for tag
          { 'tag' => ::Language::Tag.for(json_var['tag'], true).tag }
        rescue
          raise ArgumentError, "Could not identify language tag for: #{json_var.inspect}"
        end

        def from_serialized_form_impl(json_var)
          return nil if json_var.nil?
          json_var.slice('tag').merge(rehydrate_data_for(json_var['tag']))
        rescue
          raise ArgumentError, "Could not identify language tag for: #{json_var.inspect}"
        end

        def rehydrate_data_for(tag)
          lang_tag = ::Language::Tag.for(tag, true)
          {
            'script' => lang_tag.script&.subtag,
            'lang' => lang_tag.lang.subtag
          }.compact
        end

        def valid?(json_var)
          json_var.blank? || rehydrate_data_for(json_var['tag'])
        rescue
          false
        end
      end
    end
  end
end
