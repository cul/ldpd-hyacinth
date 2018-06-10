namespace :hyacinth do
  namespace :hyacinth3_upgrade do

    task :generate_uuids_and_data_file_paths_for_existing_records => :environment do
      puts 'Generating UUIDs and data_files for existing records...'
      batch_size = 1000
      DigitalObjectRecord.select(:id, :uuid, :data_file_path).where(uuid: nil).find_in_batches(batch_size: batch_size).with_index do |batch, batch_number|
        batch.each do |digital_object_record|
          if digital_object_record.uuid.nil?
            digital_object_record.uuid = SecureRandom.uuid
            digital_object_record.data_file_path = Hyacinth::Utils::PathUtils.data_file_path_for_uuid(digital_object_record.uuid)
            digital_object_record.save
          end
        end
        puts "Updated #{(batch_size * batch_number) + batch.size} objects."
      end

      puts 'Done generating UUIDs for existing values.'
    end

  end
end
