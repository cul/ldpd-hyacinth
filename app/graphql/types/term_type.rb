module Types
  class TermType < Types::BaseObject
    description 'A term'

    field :id, ID, null: false, method: :uuid
    field :uri, String, null: false # this could use a custom type
    field :pref_label, String, null: false
    field :alt_labels, [String], null: true
    field :authority, String, null: true
    field :term_type, TermCategory, null: false # enum local, temporary, external
    field :custom_fields, [CustomFieldType], null: true, resolver_method: :custom_fields

    def custom_fields

      object.except('uuid', 'uri', 'pref_label', 'alt_labels', 'authority', 'term_type', 'custom_fields')
            .map { |k, v| { field: k, value: v } }
    end
  end
end
