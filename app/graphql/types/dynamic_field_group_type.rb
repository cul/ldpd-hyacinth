# frozen_string_literal: true

module Types
  class DynamicFieldGroupType < Types::BaseObject
    description 'A dynamic field group'

    field :id, ID, null: false
    field :string_key, ID, null: false
    field :display_label, String, null: false
    field :sort_order, Integer, null: false
    field :is_repeatable, Boolean, null: false
    field :export_rules, [ExportRuleType], null: true
    field :created_by, UserType, null: true
    field :updated_by, UserType, null: true
    field :children, [DynamicFieldGroupChildType], null: true, method: :ordered_children
    field :parent, DynamicFieldCollationType, null: false
    field :path, String, null: false
    field :ancestor_nodes, [DynamicFieldCollationType], "Path of categories and groups leading to this group", null: false
  end
end
