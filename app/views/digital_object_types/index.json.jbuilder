json.array!(@digital_object_types) do |digital_object_type|
  json.extract! digital_object_type, :id, :string_key, :display_label
  json.url digital_object_type_url(digital_object_type, format: :json)
end
