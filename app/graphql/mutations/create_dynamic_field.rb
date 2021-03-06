# frozen_string_literal: true

class Mutations::CreateDynamicField < Mutations::BaseMutation
  argument :string_key, ID, required: true
  argument :display_label, String, required: true
  argument :field_type, String, required: true
  argument :sort_order, Integer, required: false
  argument :is_facetable, Boolean, required: false
  argument :filter_label, String, required: false
  argument :select_options, String, required: false
  argument :is_keyword_searchable, Boolean, required: false
  argument :is_title_searchable, Boolean, required: false
  argument :is_identifier_searchable, Boolean, required: false
  argument :controlled_vocabulary, String, required: false
  argument :dynamic_field_group_id, ID, required: true

  field :dynamic_field, Types::DynamicFieldType, null: true

  def resolve(**attributes)
    ability.authorize! :create, DynamicField

    attributes[:created_by] = context[:current_user]
    attributes[:updated_by] = context[:current_user]
    dynamic_field = DynamicField.create!(**attributes)

    { dynamic_field: dynamic_field }
  end
end
