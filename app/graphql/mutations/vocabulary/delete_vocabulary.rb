# frozen_string_literal: true

class Mutations::Vocabulary::DeleteVocabulary < Mutations::BaseMutation
  argument :string_key, ID, required: true

  field :vocabulary, Types::VocabularyType, null: true

  def resolve(string_key:)
    vocabulary = Vocabulary.find_by!(string_key: string_key)

    ability.authorize! :destroy, vocabulary

    vocabulary.destroy!

    { vocabulary: vocabulary }
  end
end
