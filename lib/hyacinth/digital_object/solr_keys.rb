# frozen_string_literal: true

module Hyacinth
  module DigitalObject
    module SolrKeys
      # TODO: Eventually maybe all solr key could be stored in this class in order
      # to centralize where that information is.

      def self.for_dynamic_field(path)
        'df_' + path.map { |p| p.camelcase(:lower) }.join('_') + '_ssim'
      end
    end
  end
end
