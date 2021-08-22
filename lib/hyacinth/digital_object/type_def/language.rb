# frozen_string_literal: true

module Hyacinth
  module DigitalObject
    module TypeDef
      class Language < Hyacinth::DigitalObject::TypeDef::Base
        def to_serialized_form_impl(language)
          return nil if language.nil?
          { 'tag' => ::Language::Tag.for(language, true).tag }
        end

        def from_serialized_form_impl(json_var)
          return nil if json_var.nil?
          json_var['tag']
        end
      end
    end
  end
end
