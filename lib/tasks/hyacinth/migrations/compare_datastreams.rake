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
              status += 8 unless Hyacinth::Utils::FedoraUtils::DatastreamMigrations.compare_content_descriptors(lower_ds, upper_ds, ENV['ds_root'])[:status]
              output << "#{fedora_object_pid},#{status}\n"
            end
          end
        end
      else
        puts "no pids file given"
      end
    end
    task :migrate_identical_content => :environment do
      hufd = Hyacinth::Utils::FedoraUtils::DatastreamMigrations
      repository = hufd.repository
      if ENV['pids'].present? && ENV['ds_root'].present?
        skip = ENV['skip'].to_s.to_i
        open(ENV['pids']) do |blob|
          lines = 0
          open("log/migrate_identical_content.#{Time.new.to_i}.log", 'w') do |output|
            blob.each do |line|
              lines += 1
              next unless lines > skip
              fedora_object_pid = line.strip
              fedora_object = repository.find(fedora_object_pid)
              if obj.datastreams['hyacinth_core'].nil? || obj.datastreams['hyacinth_core'].new?
                output << "#{fedora_object_pid},1\n"
                next
              end
              lower_ds = fedora_object.datastreams['content']
              upper_ds = fedora_object.datastreams['CONTENT']
              if lower_ds&.controlGroup != 'M' || upper_ds&.controlGroup != 'M'
                output << "#{fedora_object_pid},2\n"
                next
              end
              if lower_ds.dsLabel != upper_ds.dsLabel
                output << "#{fedora_object_pid},4\n"
                next
              end
              upper_desc = hufd.content_descriptor(repository, upper_ds, ENV['ds_root'])
              if upper_desc.start_with?('bytes:0') || (upper_desc != hufd.content_descriptor(repository, lower_ds, ENV['ds_root']))
                output << "#{fedora_object_pid},8\n"
                next
              end
              begin
                hyc_obj = DigitalObject::Base.find(fedora_object_pid)
                original_file_path = upper_ds.ds_label
                import_file_path = File.join(
                  repository_path,
                  upper_ds.createDate.getlocal.strftime('%Y/%m%d/%H/%M'),
                  ds.dsLocation.gsub(':', '_')
                )
                if File.exists?(import_file_path)
                  hyc_obj.instance_variable_set(:@import_file_original_file_path, original_file_path)
                  hyc_obj.instance_variable_set(:@import_file_import_path, import_file_path)
                  hyc_obj.instance_variable_set(:@import_file_import_type, DigitalObject::Asset::IMPORT_TYPE_INTERNAL)
                  lower_ds.delete
                  hyc_obj.do_file_import
                  hyc_obj.save
                  output << "#{fedora_object_pid},0\n"
                else
                  output << "#{fedora_object_pid},16\n"
                end
              rescue
                output << "#{fedora_object_pid},32\n"
              end
            end
          end
        end
      else
        puts "no pids file given" unless ENV['pids'].present?
        puts "no ds_root given" unless ENV['ds_root'].present?
      end
    end
  end
end
