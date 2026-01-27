require 'thread/pool'

namespace :hyacinth do
  namespace :index do
    indexing_logger_location = Rails.root.join("log/#{Rails.env}_indexing.log")
    indexing_logger = begin
      logger = ActiveSupport::Logger.new(indexing_logger_location)
      logger.level = :debug
      logger
    end

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

        # Delete only docs that have the hyacinth_type_si field.
        # Doing this so that we don't interfere with other docs if
        # this solr core is also used for non-Hyacinth-managed things.
        Hyacinth::Utils::SolrUtils.solr.delete_by_query 'hyacinth_type_si:["" TO *]'
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
      async = ENV['ASYNC'] == 'true'

      if ENV['PIDS'].present?
        pids = ENV['PIDS'].split(',')
      elsif ENV['PIDLIST'].present?
        pids = open(ENV['PIDLIST'],'r').map(&:strip)
      else
        puts 'Error: Please supply a value for PIDS (one or more comma-separated Hyacinth PIDs)'
        next
      end

      total = pids.length
      puts "Reindexing #{total} Digital #{total == 1 ? 'Object' : 'Objects'}..."
      progressbar = ProgressBar.create(:title => "Reindex", :starting_at => 0, :total => total, :format => '%a |%b>>%i| %p%% %c/%C %t')

      pids.each do |pid|
        begin
          if async
            Hyacinth::Queue.reindex_digital_object(pid)
          else
            DigitalObject::Base.find(pid).update_index(false) # Passing false here so that we don't do one solr commit per update
          end
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

      48.times {
        pool.process {
          sleep 1
          puts 'go'
        }
      }

      pool.shutdown

      puts 'Total time: ' + (Time.now - start_time).to_s
    end

    # NOTE: This is generally much faster than an asynchronous reindex because we lose time between jobs.  If you want
    # it to go really quickly, increase your database pool size to something like 20.
    task :multithreaded_reindex => :environment do
      if ENV['START_AT'].present?
        start_at = ENV['START_AT'].to_i
        puts 'Starting at: ' + start_at.to_s
      else
        start_at = 0
      end

      max_allowed_thread_pool_size = ActiveRecord::Base.connection_pool.size - 1
      thread_pool_size = [ENV.fetch('THREAD_POOL_SIZE', max_allowed_thread_pool_size).to_i, max_allowed_thread_pool_size].min
      puts "THREAD_POOL_SIZE is set to: #{thread_pool_size}"
      puts "Reminder: THREAD_POOL_SIZE cannot be greater than ActiveRecord::Base.connection_pool.size MINUS ONE, or else you'll get MySQL timeouts. ActiveRecord::Base.connection_pool.size is: #{ActiveRecord::Base.connection_pool.size}"

      if ENV['CLEAR'].present? && ENV['CLEAR'] == 'true'
        puts 'Clearing old index because CLEAR=true has been passed in as an option.'

        # Delete only docs that have the hyacinth_type_si field.
        # Doing this so that we don't interfere with other docs if
        # this solr core is also used for non-Hyacinth-managed things.
        Hyacinth::Utils::SolrUtils.solr.delete_by_query 'hyacinth_type_si:["" TO *]'
      end

      puts "Errors and other information will be logged to #{indexing_logger_location}"
      indexing_logger.unknown("Starting multithreaded reindex.")

      # Go through all known DigitalObjectRecords in the DB and reindex them.
      # Do this in batches so that we don't return data for millions of records in a single batch.
      total = DigitalObjectRecord.count
      error_count = 0
      puts "Reindexing #{total} Digital #{total == 1 ? 'Object' : 'Objects'}..."
      progressbar = ProgressBar.create(:title => "Reindex", :starting_at => start_at, :total => total, :format => '%a |%b>>%i| %p%% %c/%C %t')

      pool = Concurrent::ThreadPoolExecutor.new(
        min_threads: thread_pool_size,
        max_threads: thread_pool_size,
        # Don't build up tasks in a queue. Wait until a pool worker is available.
        # It's important to set some value here because a value of 0 appears to allow
        # the queue to grow infinitely, which leads to very high memory usage over time.
        max_queue: 5,
        fallback_policy: :caller_runs # If the queue is full and we try to add a task to it, run the operation synchronously
      )

      DigitalObjectRecord.find_each(batch_size: 500, start: start_at) do |digital_object_record|
        pool.post {
          begin
            DigitalObject::Base.find(digital_object_record.pid).update_index(false) # Passing false here so that we don't do one solr commit per update
          rescue => e
            error_count += 1
            indexing_logger.error("Error: Skipping #{digital_object_record.pid} (see information below)\nException: #{e.class}, Message: #{e.message}")
          end
          progressbar.increment
        }
      end

      # Tell the pool to shut down and allow in progress work to complete.
      pool.shutdown
      # Wait for all remaining work to complete.
      pool.wait_for_termination

      Hyacinth::Utils::SolrUtils.solr.commit # Only commit at the end
      progressbar.finish

      indexing_logger.unknown("Multithreaded reindex complete. Errors: #{error_count}")
      puts "Done! Errors: #{error_count}"
      puts "See log for details: #{indexing_logger_location}" if error_count > 0
    end
  end
end
