# frozen_string_literal: true

class Mutations::Vocabulary::CreateVocabulary < Mutations::BaseMutation
  argument :string_key, ID, required: true
  argument :label, String, required: true
  argument :locked, Boolean, required: false

  field :vocabulary, Types::VocabularyType, null: true

  def resolve(**attributes)
    ability.authorize! :create, Vocabulary

    vocabulary = Vocabulary.new(**attributes)

    vocabulary.save!

    { vocabulary: vocabulary }
  end
end
