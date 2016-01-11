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

      Hyacinth::Utils::DigitalObjectUtils.in_batches(start_at, 500, "Reindex") do |digital_object_record|
        begin
          DigitalObject::Base.find(digital_object_record.pid).update_index(false) # Passing false here so that we don't do one solr commit per update
        rescue RestClient::Unauthorized, Rubydora::RubydoraError => e
          Rails.logger.error('Error: Skipping ' + digital_object_record.pid + "\nException: #{e.class}, Message: #{e.message}")
        end
      end

    end

    task :update_objects => :environment do
      if ENV['START_AT'].present?
        start_at = ENV['START_AT'].to_i
        puts 'Starting at: ' + start_at.to_s
      else
        start_at = 0
      end

      # Go through all known DigitalObjectRecords in the DB and reindex them.
      # Do this in batches so that we don't return data for millions of records, all at once.

      Hyacinth::Utils::DigitalObjectUtils.in_batches(start_at, 500, "Reindex") do |digital_object_record|
        begin
          object = DigitalObject::Base.find(digital_object_record.pid)
          object.save
        rescue RestClient::ResourceNotFound, RestClient::Unauthorized, Rubydora::RubydoraError => e
          Rails.logger.error('Error: Skipping ' + digital_object_record.pid + "\nException: #{e.class}, Message: #{e.message}")
        end
      end
    end

    task :update_object_list => :environment do
      path = ENV['PIDS']
      raise "PIDS argument is required" unless path

      # Go through all known DigitalObjectRecords in the DB and reindex them.
      # Do this in batches so that we don't return data for millions of records, all at once.

      Hyacinth::Utils::DigitalObjectUtils.in_list(path, :pid) do |digital_object_record|
        begin
          object = DigitalObject::Base.find(digital_object_record.pid)
          object.save
        rescue RestClient::ResourceNotFound, RestClient::Unauthorized, Rubydora::RubydoraError => e
          Rails.logger.error('Error: Skipping ' + digital_object_record.pid + "\nException: #{e.class}, Message: #{e.message}")
        end
      end
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
