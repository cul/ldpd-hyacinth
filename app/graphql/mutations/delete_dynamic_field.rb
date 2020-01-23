# frozen_string_literal: true

class Mutations::DeleteDynamicField < Mutations::BaseMutation
  argument :string_key, ID, required: true

  field :dynamic_field, Types::DynamicFieldType, null: true

  def resolve(string_key:)
    dynamic_field = DynamicField.find_by!(string_key: string_key)

    ability.authorize! :delete, dynamic_field

    dynamic_field.destroy!

    { dynamic_field: dynamic_field }
  end
end