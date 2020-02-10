# frozen_string_literal: true

class Mutations::UpdateDynamicFieldGroup < Mutations::BaseMutation
  argument :string_key, ID, required: true
  argument :display_label, String, required: false
  argument :sort_order, Integer, required: false
  argument :is_repeatable, Boolean, required: false
  argument :export_rules, [GraphQL::Types::JSON], required: false

  field :dynamic_field_group, Types::DynamicFieldGroupType, null: true

  def resolve(string_key:, **attributes)
    dynamic_field_group = DynamicFieldGroup.find_by!(string_key: string_key)

    ability.authorize! :update, dynamic_field_group

    attributes[:updated_by] = context[:current_user]
    dynamic_field_group.update!(**attributes)

    { dynamic_field_group: dynamic_field_group }
  end
end