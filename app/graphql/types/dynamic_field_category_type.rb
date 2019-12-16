# frozen_string_literal: true

module Types
  class DynamicFieldCategoryType < Types::BaseObject
    description 'A dynamic field category'

    field :id, ID, null: false
    field :display_label, String, null: false
    field :sort_order, Integer, null: false
    field :children, [DynamicFieldGroupType], null: true
  end
end
