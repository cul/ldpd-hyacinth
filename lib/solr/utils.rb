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

    # Escape characters that have special meaning to Solr query parser:
    # These include: + - & | ! ( ) { } [ ] ^ " ~ * ? : \ /
    # Does not escape whitespace. You need to do that on your own.
    def self.escape(val, escape_spaces = false)
      return val if val.is_a?(TrueClass) || val.is_a?(FalseClass)
      escaped_val = RSolr.solr_escape(val)
      if escape_spaces
        escaped_val.gsub(' ', '\ ')
      else
        escaped_val
      end
    end
  end
end
