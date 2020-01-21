# frozen_string_literal: true

module Mutations
  module Term
    class BaseMutation < Mutations::BaseMutation
      def find_unlocked_vocabulary!(string_key)
        vocabulary = ::Vocabulary.find_by!(string_key: string_key)
        raise GraphQL::ExecutionError, 'Vocabulary is locked.' if vocabulary.locked?
        vocabulary
      end
    end
  end
end
