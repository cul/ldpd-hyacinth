# frozen_string_literal: true

class Mutations::Term::BaseMutation < Mutations::BaseMutation
  def find_vocabulary!(string_key)
    vocabulary = Vocabulary.find_by!(string_key: string_key)
    raise GraphQL::ExecutionError, 'Vocabulary is locked.' if vocabulary.locked?
    vocabulary
  end
end
