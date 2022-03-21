# frozen_string_literal: true

class Enums::FilterMatchEnum < Types::BaseEnum
  Solr::Params::VALID_FILTER_MATCHES.each_key do |filter_key|
    value str_to_gql_enum(filter_key), filter_key.downcase.gsub(/_+/, ' '), value: filter_key
  end
end
