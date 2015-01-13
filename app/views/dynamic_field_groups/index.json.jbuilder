json.array!(@dynamic_field_groups) do |dynamic_field_group|
  json.extract! dynamic_field_group, :id, :string_key, :display_label, :parent_dynamic_field_group_id, :sort_order, :is_repeatable, :xml_datastream_id, :xml_translation_json, :dynamic_field_group_category_id, :created_by_id, :updated_by_id
  json.url dynamic_field_group_url(dynamic_field_group, format: :json)
end
