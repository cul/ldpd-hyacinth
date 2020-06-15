# frozen_string_literal: true

module Hyacinth
  module DigitalObject
    module Facets
      # Return all solr keys for facetable dynamic fields.
      def self.all_solr_keys
        all_facetable_fields.map { |config| SolrKeys.for_dynamic_field(config[:path]) }
      end

      # Returns configuration for all facetable dynamic fields.
      def self.all_facetable_fields
        Hyacinth::DynamicFieldsMap.new(*DynamicFieldCategory.metadata_forms.keys)
                                  .all_fields
                                  .select { |c| c[:is_facetable] }
      end

      # Return hash mapping solr keys to facet display label
      def self.facet_display_label_map
        all_facetable_fields.map { |config|
          [SolrKeys.for_dynamic_field(config[:path]), config[:filter_label] || config[:display_label]]
        }.to_h
      end
    end
  end
end
