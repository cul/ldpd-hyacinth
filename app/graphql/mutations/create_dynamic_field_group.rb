# frozen_string_literal: true

class Mutations::CreateDynamicFieldGroup < Mutations::BaseMutation
  argument :string_key, ID, required: true
  argument :display_label, String, required: true
  argument :sort_order, Integer, required: false
  argument :is_repeatable, Boolean, required: false
  argument :export_rules, [Inputs::ExportRuleInput], required: false
  argument :parent_id, ID, required: true
  argument :parent_type, String, required: true

  field :dynamic_field_group, Types::DynamicFieldGroupType, null: true

  def resolve(**attributes)
    ability.authorize! :create, DynamicFieldGroup

    export_rules = attributes.delete(:export_rules)
    attributes[:export_rules_attributes] = export_rules.map(&:to_h) unless export_rules.nil?

    attributes[:created_by] = context[:current_user]
    attributes[:updated_by] = context[:current_user]

    dynamic_field_group = DynamicFieldGroup.create!(**attributes)

    { dynamic_field_group: dynamic_field_group }
  end
end
