# frozen_string_literal: true

module Hyacinth
  module DigitalObject
    module TypeDef
      class DynamicFieldData < Hyacinth::DigitalObject::TypeDef::JsonSerializableCollection
        TYPE_TO_FORM_TYPE = {
          rights_metadata: ['item_rights', 'asset_rights'],
          descriptive_metadata: ['descriptive']
        }.freeze

        def initialize(type)
          super()
          raise ArgumentError, "type '#{type}' is invalid" unless TYPE_TO_FORM_TYPE.keys.map(&:to_s).include?(type.to_s)

          # Generate Dynamic Field Map
          @field_map = Hyacinth::DynamicFieldsMap.generate(TYPE_TO_FORM_TYPE[type])
        end

        # TODO: Pull in field name change.

        def from_serialized_form_impl(json_var)
          return nil if json_var.nil?
          raise ArgumentError, "Expected hash, but got: #{json_var.class}" unless json_var.is_a?(Hash)

          terms_map = extract_terms(@field_map, json_var)

          search_query = terms_map.map { |vocab, terms|
            uris = terms.map { |t| "\"#{t['uri']}\"" }.compact.join(' OR ')
            "(vocabulary:\"#{vocab}\" AND uri:(#{uris}))"
          }.join(' OR ')

          # TODO: This search query has to be a POST request because it will be large.
          search_results = Hyacinth::Config.term_search_adapter.search do |solr_params|
            solr_params.q(search_query, escape: false)
          end

          # Retrieve all custom fields for vocabularies so we know which fields should be add to the hash.
          # This ensure that there's always a value for the all the custom fields defined and does not add
          # any custom fields that have been removed from the Vocabulary since indexing.
          vocab_to_custom_fields = Vocabulary.where(string_key: terms_map.keys)
                                             .map { |v| [v.string_key, v.custom_fields] }
                                             .to_h

          terms_map.each do |vocab, terms|
            custom_field_definitions = vocab_to_custom_fields[vocab]

            terms.each do |term_hash|
              solr_term_hash = search_results['response']['docs'].find do |result|
                result['uri'] == term_hash['uri'] && result['vocabulary'] == vocab
              end

              next if solr_term_hash.blank?

              full_term = {}

              { 'authority' => '', 'pref_label' => '', 'alt_labels' => [], 'term_type' => '' }.map do |key, default|
                full_term[key] = solr_term_hash.fetch(key, default)
              end

              custom_field_values = JSON.parse(solr_term_hash['custom_fields'])
              custom_field_definitions.each { |field_key, _config| full_term[field_key] = custom_field_values.fetch(field_key, '') }

              term_hash.slice!('uri')
              term_hash.merge!(full_term)
            end
          end

          json_var
        end

        def to_serialized_form_impl(json_var)
          return nil if json_var.nil?
          raise ArgumentError, "Expected hash, but got: #{json_var.class}" unless json_var.is_a?(Hash)

          # Dehydrate URI terms. Remove all other fields in terms hash except for 'uri'
          extract_terms(@field_map, json_var).values.sum([]).each { |t| t.slice!('uri') }

          json_var
        end

        def extract_terms(map, data)
          terms = {}

          data.each do |field_or_group_key, value|
            next unless map.key?(field_or_group_key)

            reduced_map = map[field_or_group_key]

            case reduced_map[:type]
            when 'DynamicFieldGroup'
              next unless value.is_a?(Array)

              value.each do |v|
                extract_terms(reduced_map[:children], v).each do |vocab, new_terms|
                  terms[vocab] = terms.fetch(vocab, []).concat(new_terms)
                end
              end
            when 'DynamicField'
              next unless reduced_map[:field_type] == DynamicField::Type::CONTROLLED_TERM
              next unless value.is_a?(Hash)
              vocab = reduced_map[:controlled_vocabulary]

              terms[vocab] = [] unless terms.key?(vocab)
              terms[vocab] += [value]
            end
          end

          terms
        end
      end
    end
  end
end
