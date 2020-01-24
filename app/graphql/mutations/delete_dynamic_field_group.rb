# frozen_string_literal: true

class Mutations::DeleteDynamicFieldGroup < Mutations::BaseMutation
  argument :string_key, ID, required: true

  field :dynamic_field_group, Types::DynamicFieldGroupType, null: true

  def resolve(string_key:)
    dynamic_field_group = DynamicFieldGroup.find_by!(string_key: string_key)

    ability.authorize! :delete, dynamic_field_group

    dynamic_field_group.destroy!

    { dynamic_field_group: dynamic_field_group }
  end
end
