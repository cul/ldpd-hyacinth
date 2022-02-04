# frozen_string_literal: true

module Hyacinth
  module DynamicFieldDataHelper
    # Format term (either Term object or hash) to the expected format for dynamic field data. Custom fields
    # must be defined at the top level of the hash along side core term fields (like, term_type, etc).
    #
    # @param [Term|Hash] term object to be formated
    # @param [Array<String>] custom field keys that should be represented in the returning hash/
    def self.format_term(term, custom_fields)
      if term.is_a? Term
        new_term = Term::CORE_FIELDS.index_with { |f| term.send(f) }
        new_term['alt_labels'] = [] if new_term['alt_labels'].nil?
        custom_fields_data = term.custom_fields
      elsif term.is_a? Hash
        new_term = { 'authority' => nil, 'alt_labels' => [] }.merge(term.slice(*Term::CORE_FIELDS))
        custom_fields_data = JSON.parse(term['custom_fields'])
      else
        raise ArgumentError, 'term must be a Hash or Term object'
      end

      custom_fields.each { |f| new_term[f] = custom_fields_data.fetch(f, nil) }
      new_term
    end

    # Moves the data in the rehydrate_with hash to the orginal term hash.
    def self.rehydrate_term(term, rehydrate_with)
      term.slice!('uri')
      term.merge!(rehydrate_with)
    end
  end
end
