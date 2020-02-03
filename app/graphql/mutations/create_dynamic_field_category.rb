# frozen_string_literal: true

class Mutations::CreateDynamicFieldCategory < Mutations::BaseMutation
  argument :display_label, String, required: true
  argument :sort_order, Integer, required: false

  field :dynamic_field_category, Types::DynamicFieldCategoryType, null: true

  def resolve(**attributes)
    ability.authorize! :create, DynamicFieldCategory

    dynamic_field_category = DynamicFieldCategory.create!(**attributes)

    { dynamic_field_category: dynamic_field_category }
  end
end
