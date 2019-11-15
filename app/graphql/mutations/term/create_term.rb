class Mutations::Term::CreateTerm < Mutations::BaseMutation
  argument :vocabulary_string_key, ID, required: true
  argument :string_key, ID, required: true
  argument :pref_label, String, required: true
  argument :alt_label, [String], required: false
  argument :authority, String, required: false
  argument :uri, String, required: false
  argument :term_type, Types::TermCategory, required: false # enum local, temporary, external

  # custom fields have to go somewhere in there

  field :term, Types::TermType, null: true

  def resolve(vocabulary_string_key, **attributes)
    ability.authorize! :create, :term

    response = URIService.connection.create_term(vocabulary_string_key, attributes)

    raise(GraphQL::ExecutionError, response.data['errors'].map { |e| e['title'] }.join('; ')) if response.errors?

    { term: response.data.term }
  end
end
