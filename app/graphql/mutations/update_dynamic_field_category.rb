# frozen_string_literal: true

class Mutations::UpdateDynamicFieldCategory < Mutations::BaseMutation
  argument :id, Integer, required: true
  argument :display_label, String, required: false
  argument :sort_order, Integer, required: false

  field :dynamic_field_category, Types::DynamicFieldCategoryType, null: true

  def resolve(id:, **attributes)
    dynamic_field_category = DynamicFieldCategory.find_by!(id: id)

    ability.authorize! :update, dynamic_field_category

    dynamic_field_category.update!(**attributes)

    { dynamic_field_category: dynamic_field_category }
  end
end
