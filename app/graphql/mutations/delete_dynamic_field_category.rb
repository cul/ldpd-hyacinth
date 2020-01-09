# frozen_string_literal: true

class Mutations::DeleteDynamicFieldCategory < Mutations::BaseMutation
  argument :id, ID, required: true

  field :dynamic_field_category, Types::DynamicFieldCategoryType, null: true

  def resolve(id:)
    dynamic_field_category = DynamicFieldCategory.find_by!(id: id)

    ability.authorize! :delete, dynamic_field_category

    dynamic_field_category.destroy!

    { dynamic_field_category: dynamic_field_category }
  end
end