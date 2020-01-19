# frozen_string_literal: true

module Mutations
  module Term
    class CreateTerm < Mutations::Term::BaseMutation
      argument :vocabulary_string_key, ID, required: true
      argument :pref_label, String, required: true
      argument :alt_labels, [String], required: false
      argument :authority, String, required: false
      argument :uri, String, required: false
      argument :term_type, Types::TermCategory, required: false # enum local, temporary, external
      argument :custom_fields, [Types::CustomFieldAttributes], required: false

      field :term, Types::TermType, null: true

      def resolve(vocabulary_string_key:, custom_fields: [], **attributes)
        ability.authorize! :create, ::Term

        vocabulary = find_unlocked_vocabulary!(vocabulary_string_key)

        term = ::Term.new(**attributes)
        term.vocabulary = vocabulary

        custom_fields.each do |custom_field|
          field = custom_field['field']
          value = custom_field['value']

          next unless vocabulary.custom_fields.keys.include?(field)
          term.set_custom_field(field, value)
        end

        term.save!

        { term: term }
      end
    end
  end
end
