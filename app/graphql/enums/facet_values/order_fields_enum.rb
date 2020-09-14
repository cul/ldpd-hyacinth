# frozen_string_literal: true

class Enums::FacetValues::OrderFieldsEnum < Types::BaseEnum
  graphql_name("FacetOrderFieldsEnum")
  value 'COUNT', 'sorting by relevance score', value: 'count'
  value 'INDEX', 'sorting by value alphabetically', value: 'index'
end
