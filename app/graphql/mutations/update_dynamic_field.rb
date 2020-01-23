# frozen_string_literal: true

class Mutations::UpdateDynamicField < Mutations::BaseMutation
  argument :string_key, ID, required: true
  argument :display_label, String, required: true
  argument :sort_order, Integer, required: true
  argument :is_facetable, Boolean, required: true
  argument :filter_label, String, required: false
  argument :select_options, String, required: false
  argument :is_keyword_searchable, Boolean, required: true
  argument :is_title_searchable, Boolean, required: true
  argument :is_identifier_searchable, Boolean, required: true
  argument :controlled_vocabulary, String, required: false
  argument :dynamic_field_group_id, ID, required: true


  field :dynamic_field, Types::DynamicFieldType, null: true

  def resolve(string_key:, **attributes)
    dynamic_field = DynamicField.find_by!(string_key: string_key)

    ability.authorize! :update, dynamic_field

    attributes[:updated_by] = context[:current_user]
    dynamic_field.update!(**attributes)

    { dynamic_field: dynamic_field }
  end
end