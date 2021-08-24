# frozen_string_literal: true

module Hyacinth
  # Provides app-wide helpers for language information.

  module Language
    def self.allowed_lang_value?(tag_value)
      ::Language::Tag.for(tag_value)
    rescue
      false
    end

    def self.load_default_subtags!
      Rails.application.config_for(:lang).fetch(:default_lang_subtags, {}).each do |subtag, attributes|
        subtag_atts = attributes.merge(subtag: subtag).map { |k, v| [k, Array[v]] }.to_h.with_indifferent_access
        Hyacinth::Language::SubtagLoader.new(nil).load_resolved_attributes(subtag_atts)
      end
    end
  end
end
