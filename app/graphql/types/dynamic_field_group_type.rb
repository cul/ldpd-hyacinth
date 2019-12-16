# frozen_string_literal: true

module Types
  class DynamicFieldGroupType < Types::BaseObject
    description 'A dynamic field group'

    field :id, ID, null: false
    field :string_key, ID, null: false
    field :display_label, String, null: false
    field :sort_order, Integer, null: false
    field :is_repeatable, Boolean, null: false
    field :export_rules, [GraphQL::Types::JSON], null: true
    field :children, [DynamicFieldGroupChildType], null: true
    field :parent, DynamicFieldCategoryType, null: true
  end
end
