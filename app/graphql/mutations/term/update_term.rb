# frozen_string_literal: true

class Mutations::Term::UpdateTerm < Mutations::Term::BaseMutation
  argument :vocabulary_string_key, ID, required: true
  argument :uri, String, required: true
  argument :pref_label, String, required: false
  argument :alt_labels, [String], required: false
  argument :authority, String, required: false
  argument :custom_fields, [Types::CustomFieldAttributes], required: false

  field :term, Types::TermType, null: true

  def resolve(vocabulary_string_key:, uri:, custom_fields: [], **attributes)
    vocabulary = find_vocabulary!(vocabulary_string_key)
    term = Term.find_by!(vocabulary: vocabulary, uri: uri)

    ability.authorize! :update, term

    term.assign_attributes(**attributes) # updates, but doesn't save.

    custom_fields.each do |f, v|
      next unless vocabulary.custom_fields.keys.include?(f)
      term.set_custom_field(f, v)
    end

    term.save!

    { term: term }
  end
end
