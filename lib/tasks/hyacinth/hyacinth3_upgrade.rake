namespace :hyacinth do
  namespace :hyacinth3_upgrade do

    task :generate_uuids_for_existing_records => :environment do
      puts 'Generating UUIDs and data_files for existing records...'
      batch_size = 1000
      DigitalObjectRecord.select(:id, :uuid).where(uuid: nil).find_in_batches(batch_size: batch_size).with_index do |batch, batch_number|
        batch.each do |digital_object_record|
          if digital_object_record.uuid.nil?
            digital_object_record.uuid = SecureRandom.uuid
            digital_object_record.save
          end
        end
        puts "Updated #{(batch_size * batch_number) + batch.size} objects."
      end

      puts 'Done generating UUIDs for existing values.'
    end

  end
end
