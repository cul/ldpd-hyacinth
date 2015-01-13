json.array!(@dynamic_field_group_categories) do |dynamic_field_group_category|
  json.extract! dynamic_field_group_category, :id, :display_label, :sort_order
  json.url dynamic_field_group_category_url(dynamic_field_group_category, format: :json)
end
