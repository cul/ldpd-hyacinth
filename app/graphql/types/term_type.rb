# frozen_string_literal: true

module Types
  class TermType < Types::BaseObject
    description 'A term'

    field :id, ID, null: false, method: :uid
    field :uri, String, null: false # this could use a custom type
    field :pref_label, String, null: false
    field :alt_labels, [String], null: false, resolver_method: :alt_labels
    field :authority, String, null: true
    field :term_type, TermCategory, null: false # enum local, temporary, external
    field :custom_fields, [CustomFieldType], null: true, resolver_method: :custom_fields

    def alt_labels
      object.is_a?(Term) ? object.alt_labels : object.fetch(:alt_labels, [])
    end

    # Need to support both a Hash or an ActiveRecord object
    def custom_fields
      vocabulary = object.is_a?(Hash) ? Vocabulary.find_by!(string_key: object['vocabulary']) : object.vocabulary

      custom_field_values = object.is_a?(Hash) ? JSON.parse(object['custom_fields']) : object.custom_fields
      custom_field_values.deep_stringify_keys!

      vocabulary.custom_fields
                .map { |k, _v| { field: k, value: custom_field_values[k] } }
                .sort_by { |c| c[:field] }
    end
  end
end
