namespace :hyacinth do

  namespace :debug do

    task :check_for_hyacinth_ds_presence => :environment do

      fedora_url = ActiveFedora.config.credentials[:url]
      total = DigitalObjectRecord.count
      non_200_pids = []
      num_non_200_pids = 0

      start_time = Time.now

        pool = Thread.pool(50)

        i = 0

        DigitalObjectRecord.find_each(batch_size: 500, start: 0) do |digital_object_record|

          pid = digital_object_record.pid

          pool.process {

            uri = URI(fedora_url + '/objects/' + pid)

            Net::HTTP.start(uri.host, uri.port) do |http|
              request = Net::HTTP::Get.new uri

              response = http.request request # Net::HTTPResponse object
              if response.code != '200'
                non_200_pids << pid
                num_non_200_pids += 1
                puts 'Error: ' + pid + ' -> status: ' + response.code
              end
            end

            i += 1
            puts "Found #{num_non_200_pids} [#{i}/#{total}]"
          }
        end

        pool.shutdown

        puts non_200_pids.join(",")

        puts 'Total time: ' + (Time.now - start_time).to_s

    end

  end

end
