json.array!(@projects) do |project|
  json.extract! project, :id, :display_label, :string_key, :fedora_identifier, :next_base_filename_number
  json.url project_url(project, format: :json)
end
