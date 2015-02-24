require 'thread/pool'

namespace :hyacinth do
  namespace :data_migration do

    task :update_original_file_path_storage => :environment do

      if ENV['START_AT'].present?
        start_at = ENV['START_AT'].to_i
        puts 'Starting at: ' + start_at.to_s
      else
        start_at = 0
      end


      total = DigitalObjectRecord.count
      i = start_at

      DigitalObjectRecord.find_each(batch_size: 500, start: start_at) do |digital_object_record|
        obj = DigitalObject::Base.find(digital_object_record.pid)

        puts 'Processing ' + digital_object_record.pid + ' ...'

        if obj.state != 'D' && obj.is_a?(DigitalObject::Asset)
          obj.set_original_file_path(obj.get_original_file_path)
          obj.get_original_file_path
          puts "Updated Asset - #{i} of #{total}"
        else
          puts "Skipping non-Asset (or deleted) object - #{i} of #{total}"
        end

        i += 1
      end

    end

  end
end
