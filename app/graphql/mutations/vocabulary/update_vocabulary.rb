# frozen_string_literal: true

class Mutations::Vocabulary::UpdateVocabulary < Mutations::BaseMutation
  argument :string_key, ID, required: true
  argument :label, String, required: false
  argument :locked, Boolean, required: false

  field :vocabulary, Types::VocabularyType, null: true

  def resolve(string_key:, **attributes)
    vocabulary = Vocabulary.find_by!(string_key: string_key)

    ability.authorize! :update, vocabulary

    vocabulary.update!(**attributes)

    { vocabulary: vocabulary }
  end
end
