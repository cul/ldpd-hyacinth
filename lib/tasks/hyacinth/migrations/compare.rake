require 'thread/pool'

namespace :hyacinth do
  namespace :migrations do

    task :compare_legacy_content => :environment do
      repository = Hyacinth::Utils::FedoraUtils::DatastreamMigrations.repository
      if ENV['pids'].present?
        skip = ENV['skip'].to_s.to_i
        open(ENV['pids']) do |blob|
          lines = 0
          open('log/legacy_content_compare.log', 'w') do |output|
            blob.each do |line|
              lines += 1
              next unless lines > skip
              fedora_object_pid = line.strip
              obj = repository.find(fedora_object_pid)
              lower_ds = obj.datastreams['content']
              upper_ds = obj.datastreams['CONTENT']
              status = 0
              left = lower_ds && !lower_ds.new?
              status += 1 unless left
              right = upper_ds && !upper_ds.new?
              status += 2 unless right
              status += 4 unless lower_ds&.dsLabel == upper_ds&.dsLabel
              status += 8 unless Hyacinth::Utils::FedoraUtils::DatastreamMigrations.compare_content_descriptors(lower_ds, upper_ds)[:status]
              output << "#{fedora_object_pid},#{status}\n"
              puts "#{lines}\t#{fedora_object_pid}\t#{status}"
            end
          end
        end
      else
        puts "no pids file given"
      end
    end
  end
end
