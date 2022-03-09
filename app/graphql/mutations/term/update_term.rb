# frozen_string_literal: true

module Mutations
  module Term
    class UpdateTerm < Mutations::BaseMutation
      argument :vocabulary_string_key, ID, required: true
      argument :uri, String, required: true
      argument :pref_label, String, required: false
      argument :alt_labels, [String], required: false
      argument :authority, String, required: false
      argument :custom_fields, [Types::CustomFieldAttributes], required: false

      field :term, Types::TermType, null: true

      def resolve(vocabulary_string_key:, uri:, custom_fields: [], **attributes)
        vocabulary = ::Vocabulary.find_by!(string_key: vocabulary_string_key)
        term = ::Term.find_by!(vocabulary: vocabulary, uri: uri)

        ability.authorize! :update, term

        term.assign_attributes(attributes) # updates, but doesn't save.

        custom_fields.each do |f|
          field = f[:field]

          next unless vocabulary.custom_fields.key?(field)
          term.set_custom_field(field, f[:value])
        end

        term.save!

        { term: term }
      end
    end
  end
end
