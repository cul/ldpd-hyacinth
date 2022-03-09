# frozen_string_literal: true

module Types
  module Facets
    module ValueQueries
      def self.included(base)
        base.field :facet_values, Facets::ValueTypeResults, null: true do
          description "List facet values for a specified facet in a search context"
          argument :field_name, String, required: true
          argument :order_by, Inputs::FacetValues::OrderByInput, required: false, default_value: { field: 'count', direction: 'asc' }
          argument :limit, "Types::Scalar::Limit", required: true
          argument :offset, "Types::Scalar::Offset", required: false
          argument :search_params, Types::SearchAttributes, required: false#,
            #as_search_adapter_paramsprepare: ->(s_prms, ctx) { s_prms.as_search_adapter_params }
          argument :facet_filter, Types::FilterAttributes, required: false
        end
      end

      def facet_values(field_name:, order_by:, limit:, offset: 0, search_params: {}, facet_filter: nil)
        Hyacinth::Config.digital_object_search_adapter.search(search_params.as_search_adapter_params, context[:current_user]) do |solr_params|
          solr_params.rows(0)
          solr_params.facet_on(field_name) do |facet_params|
            facet_params.rows(limit)
            facet_params.start(offset)
            facet_params.sort(order_by[:field], order_by[:direction]) if order_by
            facet_params.filter(facet_filter[:values], facet_filter[:match_type]) if facet_filter
          end
        end
      end
    end
  end
end
