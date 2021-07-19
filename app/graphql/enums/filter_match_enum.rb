# frozen_string_literal: true

class Enums::FilterMatchEnum < Types::BaseEnum
  Solr::Params::VALID_FILTER_MATCHES.keys.each do |val|
    value val.upcase.tr(' ', '_'), val.downcase.gsub(/_+/, ' '), value: val
  end
end
