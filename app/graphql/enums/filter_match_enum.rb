# frozen_string_literal: true

class Enums::FilterMatchEnum < Types::BaseEnum
  Solr::Params::VALID_FILTER_MATCHES.keys.each do |val|
    value str_to_gql_enum(val), val.downcase.gsub(/_+/, ' '), value: val
  end
end
