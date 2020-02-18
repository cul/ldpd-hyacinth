# frozen_string_literal: true

class Mutations::UpdateDynamicFieldGroup < Mutations::BaseMutation
  argument :id, ID, required: true
  argument :display_label, String, required: false
  argument :sort_order, Integer, required: false
  argument :is_repeatable, Boolean, required: false
  argument :export_rules, [Inputs::ExportRuleInput], required: false
  argument :parent_id, ID, required: false
  argument :parent_type, String, required: false

  field :dynamic_field_group, Types::DynamicFieldGroupType, null: true

  def resolve(id:, **attributes)
    dynamic_field_group = DynamicFieldGroup.find(id)

    ability.authorize! :update, dynamic_field_group

    export_rules = attributes.delete(:export_rules)
    attributes[:export_rules_attributes] = export_rules.map(&:to_h) unless export_rules.nil?

    attributes[:updated_by] = context[:current_user]
    dynamic_field_group.update!(**attributes)

    { dynamic_field_group: dynamic_field_group }
  end
end
