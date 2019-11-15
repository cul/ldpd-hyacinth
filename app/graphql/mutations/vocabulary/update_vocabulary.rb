class Mutations::Vocabulary::UpdateVocabulary < Mutations::BaseMutation
  argument :string_key, ID, required: true
  argument :label, String, required: true
  argument :locked, Boolean, required: false

  field :vocabulary, Types::VocabularyType, null: true

  def resolve(**attributes)
    ability.authorize! :update, :vocabulary

    response = URIService.connection.update_vocabulary(attributes)

    raise(GraphQL::ExecutionError, response.data['errors'].map { |e| e['title'] }.join('; ')) if response.errors?

    { vocabulary: response.data.vocabulary }
  end
end
