# frozen_string_literal: true

module Types
  class DynamicFieldType < Types::BaseObject
    description 'A dynamic field'
    field :id, ID, null: false
    field :string_key, ID, null: false
    field :display_label, String, null: false
    field :sort_order, Integer, null: false
    field :field_type, String, null: false
    field :is_facetable, Boolean, null: false
    field :filter_label, String, null: true
    field :select_options, String, null: true
    field :is_keyword_searchable, Boolean, null: false
    field :is_title_searchable, Boolean, null: false
    field :is_identifier_searchable, Boolean, null: false
    field :controlled_vocabulary, String, null: true
    field :dynamic_field_group, DynamicFieldGroupType, null: true
  end
end
