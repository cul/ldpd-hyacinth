# frozen_string_literal: true

module Inputs
  class FacetValues::OrderByInput < Types::BaseInputObject
    description 'Facet Values Sort Parameters'
    graphql_name("FacetOrderByInput")

    argument :field, Enums::FacetValues::OrderFieldsEnum, required: false, default_value: 'count'
    # desc is not supported before Solr 8
    argument :direction, Enums::OrderDirectionEnum, required: false, default_value: 'asc'
  end
end
