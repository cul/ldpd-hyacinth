class Mutations::Vocabulary::CreateVocabulary < Mutations::BaseMutation
  argument :string_key, ID, required: true
  argument :label, String, required: true
  argument :locked, Boolean, required: false

  field :vocabulary, Types::VocabularyType, null: true

  def resolve(**attributes)
    ability.authorize! :create, :vocabulary

    response = URIService.connection.create_vocabulary(attributes)

    raise(GraphQL::ExecutionError, response.data['errors'].map { |e| e['title'] }.join('; ')) if response.errors?

    { vocabulary: response.data.vocabulary }
  end
end
