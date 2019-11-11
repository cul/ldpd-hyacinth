module Types
  class VocabularyType < Types::BaseObject
    description 'A vocabulary'

    field :string_key, ID, null: false
    field :label, String, null: false
    field :custom_field_definitions, [CustomFieldDefinitionType], null: true, resolver_method: :custom_field_definitions

    field :terms, [TermType], null: true do
      argument :limit, Integer, required: true
      argument :offset, Integer, required: false
      argument :query, String, required: false
      argument :filters, [FilterAttributes], required: false
    end

    field :term, TermType, null: true do
      argument :uri, ID, required: true
    end

    def custom_field_definitions
      object['custom_fields'].map { |k, h| { field_key: k }.merge(h) }
    end

    def term(uri:)
      ability.authorize!(:read, :term)
      response = URIService.connection.term(object['string_key'], uri)
      raise(GraphQL::ExecutionError, response.data['errors'].map { |e| e['title'] }.join('; ')) if response.errors?
      response.data['term']
    end

    def terms(limit:, offset: 0, query: nil)
      ability.authorize!(:read, :term)
      response = URIService.connection.search_terms(object['string_key'], {})
      raise(GraphQL::ExecutionError, response.data['errors'].map { |e| e['title'] }.join('; ')) if response.errors?
      response.data['terms']
    end

    def ability
      context[:ability]
    end
  end
end
