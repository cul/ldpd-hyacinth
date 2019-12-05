# frozen_string_literal: true

module Solr
  module Utils
    SUFFIX_BY_DATA_TYPE = {
      'string'  => '_si',
      'integer' => '_ii',
      'boolean' => '_bi'
    }.freeze

    def self.suffix(data_type)
      SUFFIX_BY_DATA_TYPE[data_type]
    end

    # Escape for solr parameters
    def self.escape(str)
      if RSolr.respond_to?(:solr_escape)
        RSolr.solr_escape(str) # Newer method
      else
        RSolr.escape(str) # Fall back to older method
      end
    end
  end
end
