# frozen_string_literal: true

module Types
  class VocabularyType < Types::BaseObject
    description 'A vocabulary'

    field :string_key, ID, null: false
    field :label, String, null: false
    field :locked, Boolean, null: false
    field :custom_field_definitions, [CustomFieldDefinitionType], null: true, resolver_method: :custom_field_definitions

    field :terms, TermType.results_type, null: true, extensions: [Types::Extensions::SolrSearch]

    field :term, TermType, null: true do
      argument :uri, ID, required: true
    end

    def custom_field_definitions
      object.custom_fields.map { |k, h| { field_key: k }.merge(h) }
    end

    def term(uri:)
      term = Hyacinth::Config.term_search_adapter.find(object.string_key, uri)

      raise GraphQL::ExecutionError, 'Couldn\'t find Term' if term.nil?

      ability.authorize!(:read, Term, uid: term['uid'])

      term
    end

    def terms(limit:, offset: 0, query: nil, filters: [])
      ability.authorize!(:read, Term)

      custom_fields = object.custom_fields
      valid_filters = [
        'uri', 'pref_label', 'alt_labels', 'authority', 'term_type'
      ]

      all_valid_filters = custom_fields.keys + valid_filters

      Hyacinth::Config.term_search_adapter.search do |params|
        params.q     query
        params.start offset
        params.rows  limit
        params.fq('vocabulary', object.string_key)

        filters.each do |filter|
          # Need to convert the field name to snake_case because field names maybe provided in camelcase.
          field = filter[:field].underscore

          # Raise error if filter is not valid
          raise GraphQL::ExecutionError, "#{filter[:field]} is an invalid filter" unless all_valid_filters.include?(field)

          # Need to add a suffix to the filter if its a custom field.
          if (custom_field = custom_fields[field])
            field = "#{field}#{Solr::Utils.suffix(custom_field[:data_type])}"
          end

          params.fq(field, filter[:value])
        end
      end
    end
  end
end
