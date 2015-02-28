require 'thread/pool'

namespace :hyacinth do

  namespace :publish do

    task :by_project_string_key => :environment do

      if ENV['START_AT'].present?
        start_at = ENV['START_AT'].to_i
        puts 'Starting at: ' + start_at.to_s
      else
        start_at = 0
      end

      list_of_pids = []
      found_results = true
      page = 1
      per_page = 1000

      start_time = Time.now

      while found_results do
        search_results = DigitalObject::Base.search(
          {
            'page' => page,
            'per_page' => per_page,
            'f' => {
              'project_string_key_sim' => ['durst']
            },
            'fl' => 'pid'
          },
          false
        )

        page += 1

        if search_results['total'] > 0 && search_results['results'].length > 0
          list_of_pids += search_results['results'].map{ |result| result['pid'] }
        else
          found_results = false
        end
      end

      puts "Found #{list_of_pids.length} results.  Took #{Time.now - start_time} seconds."
      puts 'Publishing pids...'

      total = list_of_pids.length
      progressbar = ProgressBar.create(:title => "Publish", :starting_at => start_at, :total => total, :format => '%a |%b>>%i| %p%% %c/%C %t')

      list_of_pids.each do |pid|
        begin
          DigitalObject::Base.find(pid).publish
        rescue RestClient::Unauthorized, Rubydora::RubydoraError => e
          Rails.logger.error('Publish Error: Skipping ' + pid + "\nException: #{e.class}, Message: #{e.message}")
        end
        progressbar.increment
      end

      progressbar.finish

      puts "Done!"

    end

    task :delete_from_index => :environment do
      if ENV['PIDS'].present?
        pids = ENV['PIDS'].split(',')
      else
        puts 'Error: Please supply a value for PIDS (one or more comma-separated Hyacinth PIDs)'
        next
      end

      pids.each {|pid|
        Hyacinth::Utils::SolrUtils.solr.delete_by_query "pid:#{pid.gsub(':','\:')}"
      }

      Hyacinth::Utils::SolrUtils.solr.commit # Only commit at the end
    end

    task :multithreading_test => :environment do

      start_time = Time.now

      pool = Thread.pool(24)

      24.times {
        pool.process {
          sleep 1
          puts 'go'
        }
      }

      pool.shutdown

      puts 'Total time: ' + (Time.now - start_time).to_s
    end

  end

end
