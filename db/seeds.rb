DynamicFieldCategory.destroy_all
DynamicFieldGroup.destroy_all
DynamicField.destroy_all

user = User.find(1);

DynamicFieldCategory.create!({id: 1, display_label: "Descriptive Metadata", sort_order: 1})

df_group = DynamicFieldGroup.create!({id: 1, string_key: 'title', display_label: 'Title', sort_order: 0, is_repeatable: 0, parent_id: 1, created_by: user, updated_by: user, parent_type: "DynamicFieldCategory", xml_translation: '{\n    \"element\": \"mods:titleInfo\",\n    \"content\": [\n        {\n            \"element\": \"mods:nonSort\",\n            \"content\": \"{{title_non_sort_portion}}\"\n        },\n        {\n            \"element\": \"mods:title\",\n            \"content\": \"{{title_sort_portion}}\"\n        }\n    ]\n}'})

DynamicField.create!(id: 1, string_key: 'title_non_sort_portion', display_label: 'Non-Sort Portion', field_type: 'string', created_by: user, updated_by: user, dynamic_field_group: df_group)
DynamicField.create!(id: 2, string_key: 'title_sort_portion', display_label: 'Sort Portion', field_type: 'string', created_by: user, updated_by: user, dynamic_field_group: df_group)

