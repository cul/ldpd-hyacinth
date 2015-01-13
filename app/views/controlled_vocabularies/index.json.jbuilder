json.array!(@controlled_vocabularies) do |controlled_vocabulary|
  json.extract! controlled_vocabulary, :id, :pid, :string_key, :display_label, :pid_generator_id
  json.url controlled_vocabulary_url(controlled_vocabulary, format: :json)
end
