# frozen_string_literal: true

class Mutations::CreateDynamicFieldGroup < Mutations::BaseMutation
  argument :string_key, ID, required: true
  argument :display_label, String, required: true
  argument :sort_order, Integer, required: true
  argument :is_repeatable, Boolean, required: true
  argument :export_rules, [GraphQL::Types::JSON], required: false
  argument :parent_id, ID, required: true
  argument :parent_type, String, required: true

  field :dynamic_field_group, Types::DynamicFieldGroupType, null: true

  def resolve(**attributes)
    ability.authorize! :create, DynamicFieldGroup

    attributes[:created_by] = context[:current_user]
    attributes[:updated_by] = context[:current_user]
    dynamic_field_group = DynamicFieldGroup.new(**attributes)

    dynamic_field_group.save!

    { dynamic_field_group: dynamic_field_group }
  end
end
