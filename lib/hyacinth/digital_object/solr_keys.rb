# frozen_string_literal: true

module Hyacinth
  module DigitalObject
    module SolrKeys
      # TODO: Eventually maybe all solr key could be stored in this class in order
      # to centralize where that information is.

      def self.for_string_key_path(path, suffix = 'ssim')
        prefix = Array(path).map { |p| p.camelcase(:lower) }.join('_')
        "#{prefix}_#{suffix}"
      end

      def self.for_dynamic_field(path, suffix = 'ssim')
        "df_#{for_string_key_path(path, suffix)}"
      end
    end
  end
end
