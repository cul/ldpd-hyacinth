require 'thread/pool'

namespace :hyacinth do

  namespace :publish do

    def publish_object_by_pid(pid)
      begin
        obj = DigitalObject::Base.find(pid)
        obj.publish
      rescue StandardError => e
        # Errors raised on different threads won't show up on the console, so we need to print them.
        error_message = 'Publish Error: Skipping ' + pid + "\nException: #{e.class}, Message: #{e.message}"
        puts error_message
        #puts e.backtrace.join("\n")
        Rails.logger.error(error_message)
      end
    end

    task :by_project_string_key => :environment do

      if ENV['THREADS'].present?
        thread_pool_size = ENV['THREADS'].to_i
        puts "Number of threads: #{thread_pool_size}"
      else
        thread_pool_size = 1
        puts "Number of threads: #{thread_pool_size}"
      end

      if ENV['PROJECT_STRING_KEY'].present?
        project_string_key = ENV['PROJECT_STRING_KEY']
        puts 'Project string key: ' + project_string_key
      else
        puts 'Please specify a project string key (e.g. PROJECT_STRING_KEY=durst)'
        next
      end

      if ENV['START_AT'].present?
        start_at = ENV['START_AT'].to_i
        puts 'Starting at: ' + start_at.to_s
      else
        start_at = 0
      end

      # We run into autoloading issues when running in a multithreaded context,
      # so we'll have the application eager load all classes now.
      puts 'Eager loading application classes to avoid multithreading issues...'
      Rails.application.eager_load!
      puts 'Eager load done.'

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
              'project_string_key_sim' => [project_string_key]
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

      if list_of_pids.length > 0

        puts 'Publishing pids...'

        pool = Thread.pool(thread_pool_size)
        counter = 0
        mutex = Mutex.new
        total = list_of_pids.length
        start_time = Time.now

        puts 'list_of_pids size: ' + list_of_pids.length.to_s

        # Because of other gem autoloading issues, we also want to publish the first item
        # on the main thread before using a thread pool for
        # other items, and remove it from the list_of_pids using Array#shift.

        # Start up to thread_pool_size number of items on the main thread.
        # This seems to allow enough time for everything to autoload properly
        # and we don't get circular reference errors.
        (list_of_pids.length > thread_pool_size ? thread_pool_size : list_of_pids.length).times {
          some_pid = list_of_pids.shift # remove first element
          publish_object_by_pid(some_pid)
          counter += 1
          print "Published #{counter} of #{total} | #{Time.now - start_time} seconds" + "\r"
        }

        list_of_pids.each do |pid|
          pool.process {
            publish_object_by_pid(pid)
            mutex.synchronize do
              counter += 1
              print "Published #{counter} of #{total} | #{Time.now - start_time} seconds" + "\r"
            end
          }
        end

        pool.shutdown

      end

      puts "\nDone!"

    end
    task dois: :environment do
      unless ENV['dois'] && File.exist?(ENV['dois'])
        puts "dois param must be a file that exists: #{ENV['dois'] ? ENV['dois'] : 'nil'}"
      else
        csv = CSV.open(ENV['dois'], 'rb', headers: true)
        csv.each do |row|
          pid = row['_pid']
          target = row['_doi_target']
          unless pid && target
            puts "must have _pid and _doi_target; skipping : #{row.headers} #{row}"
          else
            obj = DigitalObject::Base.find(pid)
            begin
              result = (ENV['include_metadata'] != 'TRUE') ? obj.update_doi_target_url(target) : obj.update_doi_metadata(target)
            rescue DataciteErrorResponse, DataciteConnectionError, HyacinthError::DoiMissing => e
              result = false
            end
            puts result ? "SUCCESS: #{pid} #{obj.doi} to <#{target}>" : "FAILURE: #{pid} #{obj.doi} to <#{target}>"
          end
        end
      end
    end
  end

end
