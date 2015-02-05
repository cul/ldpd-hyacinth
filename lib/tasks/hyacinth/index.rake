require 'thread/pool'

namespace :hyacinth do

  namespace :index do

    task :reindex => :environment do

      if ENV['START_AT'].present?
        start_at = ENV['START_AT'].to_i
        puts 'Starting at: ' + start_at.to_s
      else
        start_at = 0
      end

      if ENV['CLEAR'].present? && ENV['CLEAR'] == 'true'
        puts 'Clearing old index because CLEAR=true has been passed in as an option.'

        # Delete only docs that have the hyacinth_type_sim field.
        # Doing this so that we don't interfere with other docs if
        # this solr core is also used for non-Hyacinth-managed things.
        Hyacinth::Utils::SolrUtils.solr.delete_by_query 'hyacinth_type_sim:["" TO *]'
      end

      # Go through all known DigitalObjectRecords in the DB and reindex them.
      # Do this in batches so that we don't return data for millions of records, all at once.

      total = DigitalObjectRecord.count
      puts "Reindexing #{total} Digital #{total == 1 ? 'Object' : 'Objects'}..."
      progressbar = ProgressBar.create(:title => "Reindex", :starting_at => start_at, :total => DigitalObjectRecord.count, :format => '%a |%b>>%i| %p%% %c/%C %t')

      DigitalObjectRecord.find_each(batch_size: 500, start: start_at) do |digital_object_record|
        begin
          DigitalObject::Base.find(digital_object_record.pid).update_index(false) # Passing false here so that we don't do one solr commit per update
        rescue RestClient::Unauthorized => e
          logger.error('Error: Skipping ' + digital_object_record.pid + "\nException Message: " + e.message)
        end
        progressbar.increment
      end

      Hyacinth::Utils::SolrUtils.solr.commit # Only commit at the end
      progressbar.finish

      puts "Done!"

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
