require 'thread/pool'

namespace :hyacinth do

  namespace :index do

    desc "Reindex asynchronously using Resque background jobs. Note: This task updates documents in Solr, but for performance reasons does NOT do a Solr commit after making changes."
    task :reindex_async => :environment do
      # If a project is specified, reindex that project. Otherwise reindex all DigitalObjects.

      project_string_key = ENV['project_string_key']
      project_pid = ENV['project_pid']
      if project_string_key.present?
        project = Project.find_by!(string_key: project_string_key)
      elsif project_pid.present?
        project = Project.find_by!(pid: project_pid)
      else
        project = nil
      end

      if project.present?
        search_params = {
          'f' => {'project_pid_sim' => [project.pid]}
        }
        total = DigitalObject::Base.search(search_params.merge({'per_page' => 0}), nil, {})['total']
        progressbar = ProgressBar.create(:title => "Queue Reindex Jobs (single project)", :starting_at => 0, :total => total, :format => '%a |%b>>%i| %p%% %c/%C %t')
        DigitalObject::Base.search_in_batches(search_params, nil, 500) do |digital_object_data|
          Hyacinth::Queue.reindex_digital_object(digital_object_data['pid'])
          progressbar.increment
        end
        progressbar.finish
      else
        total = DigitalObjectRecord.count
        progressbar = ProgressBar.create(:title => "Queue Reindex Jobs (all objects)", :starting_at => 0, :total => total, :format => '%a |%b>>%i| %p%% %c/%C %t')
        DigitalObjectRecord.find_each(batch_size: 500, start: 0) do |digital_object_record|
          Hyacinth::Queue.reindex_digital_object(digital_object_record.pid)
          progressbar.increment
        end
        progressbar.finish
      end

      puts "Done!"
    end

    desc "Triggers a solr commit.  This task comes in handy after the background jobs created by the reindex_async task have completed. As a reminder, reindex_async does not do a solr commit for each reindexed solr document."
    task :do_solr_commit => :environment do
      puts "Performing solr commit..."
      Hyacinth::Utils::SolrUtils.solr.commit
      puts "Done!"
    end

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
      progressbar = ProgressBar.create(:title => "Reindex", :starting_at => start_at, :total => total, :format => '%a |%b>>%i| %p%% %c/%C %t')

      DigitalObjectRecord.find_each(batch_size: 500, start: start_at) do |digital_object_record|
        begin
          DigitalObject::Base.find(digital_object_record.pid).update_index(false) # Passing false here so that we don't do one solr commit per update
        rescue RestClient::Unauthorized, Rubydora::RubydoraError => e
          Rails.logger.error('Error: Skipping ' + digital_object_record.pid + "\nException: #{e.class}, Message: #{e.message}")
        end
        progressbar.increment
      end

      Hyacinth::Utils::SolrUtils.solr.commit # Only commit at the end
      progressbar.finish

      puts "Done!"

    end

    task :reindex_by_pid => :environment do
      if ENV['PIDS'].present?
        pids = ENV['PIDS'].split(',')
      else
        puts 'Error: Please supply a value for PIDS (one or more comma-separated Hyacinth PIDs)'
        next
      end

      total = pids.length
      puts "Reindexing #{total} Digital #{total == 1 ? 'Object' : 'Objects'}..."
      progressbar = ProgressBar.create(:title => "Reindex", :starting_at => 0, :total => total, :format => '%a |%b>>%i| %p%% %c/%C %t')

      pids.each do |pid|
        begin
          DigitalObject::Base.find(pid).update_index(false) # Passing false here so that we don't do one solr commit per update
        rescue RestClient::Unauthorized, Rubydora::RubydoraError => e
          Rails.logger.error('Error: Skipping ' + digital_object_record.pid + "\nException: #{e.class}, Message: #{e.message}")
        end
        progressbar.increment
      end

      Hyacinth::Utils::SolrUtils.solr.commit # Only commit at the end
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
