# frozen_string_literal: true

class Mutations::DeleteDynamicFieldGroup < Mutations::BaseMutation
  argument :id, ID, required: true

  field :dynamic_field_group, Types::DynamicFieldGroupType, null: true

  def resolve(id:)
    dynamic_field_group = DynamicFieldGroup.find(id)

    ability.authorize! :delete, dynamic_field_group

    dynamic_field_group.destroy!

    { dynamic_field_group: dynamic_field_group }
  end
end
