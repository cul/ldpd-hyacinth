# frozen_string_literal: true

class Mutations::Term::DeleteTerm < Mutations::Term::BaseMutation
  argument :vocabulary_string_key, ID, required: true
  argument :uri, String, required: true

  field :term, Types::TermType, null: true

  def resolve(vocabulary_string_key:, uri:)
    vocabulary = find_vocabulary!(vocabulary_string_key)
    term = Term.find_by!(vocabulary: vocabulary, uri: uri)

    ability.authorize! :delete, term

    term.destroy!

    { term: term }
  end
end
