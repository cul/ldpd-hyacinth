# frozen_string_literal: true

module Types
  module Facets
    module ValueQueries
      def self.included(base)
        base.field :facet_values, Facets::ValueTypeResults, null: true do
          description "List facet values for a specified facet in a search context"
          argument :field_name, String, required: true
          argument :limit, "Types::Scalar::Limit", required: true
          argument :offset, "Types::Scalar::Offset", required: false
          argument :order_by, Inputs::FacetValues::OrderByInput, required: false, default_value: { field: 'count', direction: 'asc' }
          argument :search_params, Types::SearchAttributes, required: false
          argument :facet_filter, Types::FilterAttributes, required: false
        end
      end

      def facet_values(**arguments)
        search_params = arguments[:search_params] ? arguments[:search_params].prepare : {}
        facet_filter = arguments[:facet_filter]

        Hyacinth::Config.digital_object_search_adapter.search(search_params, context[:current_user]) do |solr_params|
          solr_params.rows(0)
          solr_params.facet_on(arguments[:field_name]) do |facet_params|
            facet_params.rows(arguments[:limit])
            facet_params.start(arguments[:offset])
            facet_params.sort(arguments[:order_by][:field], arguments[:order_by][:direction]) if arguments[:order_by]
            facet_params.filter(facet_filter[:values], facet_filter[:match_type]) if facet_filter
            facet_params.with_statistics!
          end
        end
      end
    end
  end
end
