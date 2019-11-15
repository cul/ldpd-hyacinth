class Mutations::Term::DeleteTerm < Mutations::BaseMutation
  argument :vocabulary_string_key, ID, required: true
  argument :uri, String, required: true

  field :term, Types::TermType, null: true

  def resolve(vocabulary_string_key:, uri:)
    ability.authorize! :delete, :term

    response = URIService.connection.delete_term(vocabulary_string_key, uri)

    raise(GraphQL::ExecutionError, response.data['errors'].map { |e| e['title'] }.join('; ')) if response.errors?

    { term: { uri: uri } }
  end
end
