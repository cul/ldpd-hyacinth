class Mutations::Vocabulary::DeleteVocabulary < Mutations::BaseMutation
  argument :string_key, ID, required: true

  field :vocabulary, Types::VocabularyType, null: true

  def resolve(string_key:)
    ability.authorize! :update, :vocabulary

    response = URIService.connection.delete_vocabulary(string_key)

    raise(GraphQL::ExecutionError, response.data['errors'].map { |e| e['title'] }.join('; ')) if response.errors?

    { vocabulary: { string_key: string_key } }
  end
end
