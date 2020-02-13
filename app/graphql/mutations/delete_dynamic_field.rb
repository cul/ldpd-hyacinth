# frozen_string_literal: true

class Mutations::DeleteDynamicField < Mutations::BaseMutation
  argument :id, ID, required: true

  field :dynamic_field, Types::DynamicFieldType, null: true

  def resolve(id:)
    dynamic_field = DynamicField.find(id)

    ability.authorize! :delete, dynamic_field

    dynamic_field.destroy!

    { dynamic_field: dynamic_field }
  end
end
