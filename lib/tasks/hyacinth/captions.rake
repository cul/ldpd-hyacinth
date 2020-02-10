require 'thread/pool'
require 'csv'
namespace :hyacinth do
  namespace :captions do

    task :update => :environment do
      unless ENV['CSV'] && File.exist?(ENV['CSV'])
        puts "please pass a CSV with the headers _pid,import_captions_path"
        next
      end

      i = 0

      CSV.table(ENV['CSV']).each do |row|
        begin

          puts "Processing #{row[:_pid]} (#{row[:import_captions_path]}) ..."
          obj = DigitalObject::Base.find(row[:_pid]) if row[:_pid].present?

          if obj && obj.state != 'D' && obj.is_a?(DigitalObject::Asset)
            obj.captions = File.read(row[:import_captions_path])
            obj.publish_after_save = (ENV['PUBLISH'] == 'true')
            obj.save
            puts "Updated Asset \"#{row[:_pid]}\" - #{i}"
          else
            puts "Skipping non-Asset (or deleted) object \"#{row[:_pid]}\" - #{i}"
          end
        rescue RestClient::Unauthorized, Rubydora::RubydoraError => e
          Rails.logger.error 'Error: Skipping ' + obj.pid + "\nException: #{e.class}, Message: #{e.message}"
        end

        i += 1
      end
    end
  end
end
