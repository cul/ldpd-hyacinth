json.array!(@xml_datastreams) do |xml_datastream|
  json.extract! xml_datastream, :id, :string_key, :display_label, :xml_translation_json
  json.url xml_datastream_url(xml_datastream, format: :json)
end
