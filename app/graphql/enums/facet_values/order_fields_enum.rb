# frozen_string_literal: true

class Enums::FacetValues::OrderFieldsEnum < Types::BaseEnum
  graphql_name("FacetOrderFieldsEnum")
  {
    'count' => 'sorting by relevance score',
    'index' => 'sorting by value alphabetically'
  }.each do |val, description|
    value val.upcase.tr(' ', '_'), description, value: val
  end
end
