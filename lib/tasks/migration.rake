# frozen_string_literal: true

namespace :hyacinth do
  # The resource original_file_name has been changed to original_file path, so this task
  # migrates values from the old field to the new field.
  task migrate_resources: :environment do
    DigitalObjectRecord.find_in_batches(batch_size: (ENV['BATCH_SIZE'] || 1000).to_i) do |records|
      records.each do |record|
        json_var = JSON.parse(Hyacinth::Config.metadata_storage.read(record.metadata_location_uri))
        next unless json_var.key?('resources')
        json_var['resources'].each do |_resource_name, resource_json_var|
          next unless resource_json_var.key?('original_filename')
          resource_json_var['original_file_path'] = resource_json_var.delete('original_filename')
        end
        Hyacinth::Config.metadata_storage.write(record.metadata_location_uri, JSON.generate(json_var))
      end
    end
  end

  # Digital Object dynamic_field_data has been renamed descriptive_metadata, so this task migrates the values to the new field.
  task migrate_dynamic_field_data: :environment do
    DigitalObjectRecord.find_in_batches(batch_size: (ENV['BATCH_SIZE'] || 1000).to_i) do |records|
      records.each do |record|
        json_var = JSON.parse(Hyacinth::Config.metadata_storage.read(record.metadata_location_uri))
        next unless json_var.key?('dynamic_field_data')
        json_var['descriptive_metadata'] = json_var.delete('dynamic_field_data')
        Hyacinth::Config.metadata_storage.write(record.metadata_location_uri, JSON.generate(json_var))
      end
    end
  end
end
