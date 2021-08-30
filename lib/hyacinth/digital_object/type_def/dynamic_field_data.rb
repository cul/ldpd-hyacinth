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

          @type = type.to_sym
        end

        def from_serialized_form_impl(json_var)
          return nil if json_var.nil?
          raise ArgumentError, "Expected hash, but got: #{json_var.class}" unless json_var.is_a?(Hash)

          rehydrate_controlled_terms(json_var)
          rehydrate_langs(json_var)
          json_var
        end

        def rehydrate_controlled_terms(json_var)
          terms_map = field_map.extract_terms(json_var)

          terms_lookup_hash = terms_map.transform_values { |values| values.map { |v| v['uri'] } }

          term_search_results = Hyacinth::Config.term_search_adapter.batch_find(terms_lookup_hash)

          # Retrieve all custom fields for vocabularies so we know which fields should be add to the hash.
          # This ensure that there's always a value for the all the custom fields defined and does not add
          # any custom fields that have been removed from the Vocabulary since indexing.
          vocab_to_custom_fields = Vocabulary.where(string_key: terms_map.keys)
                                             .map { |v| [v.string_key, v.custom_fields] }
                                             .to_h

          terms_map.each do |vocab, terms|
            custom_field_definitions = vocab_to_custom_fields[vocab]

            terms.each do |term_hash|
              solr_term_hash = term_search_results.find do |result|
                result['uri'] == term_hash['uri'] && result['vocabulary'] == vocab
              end

              next if solr_term_hash.blank?

              full_term = Hyacinth::DynamicFieldDataHelper.format_term(solr_term_hash, custom_field_definitions.keys)

              Hyacinth::DynamicFieldDataHelper.rehydrate_term(term_hash, full_term)
            end
          end
        end

        def rehydrate_langs(json_var)
          langs = field_map.extract_langs(json_var)

          langs_lookup = langs.map { |value| value['tag'] }.uniq

          lang_search_results = ::Language::Tag.where(tag: langs_lookup)

          langs_fields = lang_search_results.map { |lang|
            atts_hash = {
              'tag' => lang.tag,
              'lang' => lang.lang&.subtag,
              'script' => lang.script&.subtag
            }.compact
            [lang.tag, atts_hash]
          }.to_h

          langs.each do |lang|
            fields_hash = langs_fields[lang['tag']]

            next if fields_hash.blank?

            lang.merge!(fields_hash)
          end
        end

        def to_serialized_form_impl(json_var)
          return nil if json_var.nil?
          raise ArgumentError, "Expected hash, but got: #{json_var.class}" unless json_var.is_a?(Hash)

          # Create a copy of json_var
          json_var = json_var.deep_dup

          # Dehydrate URI terms. Remove all other fields in terms hash except for 'uri'
          field_map.extract_terms(json_var).values.sum([]).each { |t| t.slice!('uri') }
          # Dehydrate Language terms. Remove all other fields in terms hash except for 'tag'
          field_map.extract_langs(json_var).each { |t| t.slice!('tag') }
          json_var
        end

        def field_map
          Hyacinth::DynamicFieldsMap.new(*TYPE_TO_FORM_TYPE[@type])
        end
      end
    end
  end
end
