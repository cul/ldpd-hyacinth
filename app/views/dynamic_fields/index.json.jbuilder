json.array!(@dynamic_fields) do |dynamic_field|
  json.extract! dynamic_field, :id, :string_key, :display_label, :parent_dynamic_field_group_id, :sort_order, :dynamic_field_type, :additional_data_json, :is_keyword_searchable, :is_facet_field, :standalone_field_label, :is_searchable_identifier_field, :is_searchable_title_field, :is_single_field_searchable_field, :created_by_id, :updated_by_id
  json.url dynamic_field_url(dynamic_field, format: :json)
end
