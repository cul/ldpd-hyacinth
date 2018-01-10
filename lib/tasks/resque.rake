require 'resque/tasks'

# To start workers: bundle exec rake resque:start_workers RAILS_ENV=development
# To stop workers: bundle exec rake resque:stop_workers RAILS_ENV=development

task "resque:setup" => :environment
task "resque:work" => :environment

MAX_WAIT_TIME_TO_KILL_WORKERS = 120

namespace :resque do
  task :setup => :environment

  desc "Restart running workers"
  task :restart_workers => :environment do
    Rake::Task['resque:stop_workers'].invoke
    Rake::Task['resque:start_workers'].invoke
  end

  desc "Quit running workers"
  task :stop_workers => :environment do
    stop_workers
  end

  desc "Start workers"
  task :start_workers => :environment do
    run_workers(Hyacinth::Queue::QUEUES_IN_DESCENDING_PRIORITY_ORDER, RESQUE_CONFIG['workers'] || 1)
  end

  def store_pids(pids, mode)
    pids_to_store = pids
    pids_to_store += read_pids if mode == :append

    # Make sure the pid file is writable.
    File.open(File.expand_path('tmp/pids/resque.pid', Rails.root), 'w') do |f|
      f <<  pids_to_store.join(',')
    end
  end

  def read_pids
    pid_file_path = File.expand_path('tmp/pids/resque.pid', Rails.root)
    return []  if ! File.exists?(pid_file_path)

    File.open(pid_file_path, 'r') do |f|
      f.read
    end.split(',').collect {|p| p.to_i }
  end

  def stop_workers
    pids = read_pids

    if pids.empty?
      puts "No workers to kill"
    else
      # First tell workers to stop accepting new work by sending USR2 signal
      puts "\nTelling workers to finish current jobs, but not process any new jobs..."
      syscmd = "kill -s USR2 #{pids.join(' ')}"
      puts "$ #{syscmd}"
      `#{syscmd}`
      puts "\n"
      puts "Waiting for workers to finish current jobs..."
      start_time = Time.now
      while (Time.now - start_time) < MAX_WAIT_TIME_TO_KILL_WORKERS do
        sleep 1
        num_workers_working = Resque.workers.select { |w| w.working? }.length
        puts "#{num_workers_working} workers still working..."
        break if num_workers_working == 0
      end
      puts "\n"
      if Resque.workers.select { |w| w.working? }.length > 0
        puts "Workers are still running, but wait time of #{MAX_WAIT_TIME_TO_KILL_WORKERS} has been exceeded. Sending QUIT signal anyway."
      else
        puts 'Workers are no longer processing any jobs. Sending QUIT signal.'
      end
      syscmd = "kill -s QUIT #{pids.join(' ')}"
      puts "$ #{syscmd}"
      `#{syscmd}`
      store_pids([], :write)
      puts "\n"
    end
    # Unregister old workers
    Resque.workers.each {|w| w.unregister_worker}
  end

  # Start a worker with proper env vars and output redirection
  def run_workers(queue_names, count = 1)
    puts "Starting #{count} worker(s) with QUEUES: #{queue_names.join(',')}"

    ##  make sure log/resque_err, log/resque_stdout are writable.
    ops = {:pgroup => true, :err => [(Rails.root + "log/resque_err").to_s, "a"],
                            :out => [(Rails.root + "log/resque_stdout").to_s, "a"]}
    env_vars = {
      "QUEUES" => queue_names.join(','),
      'RAILS_ENV' => Rails.env.to_s,
      'TERM_CHILD' => '1',
      'INTERVAL' => '0.2' # The default interval is 5 (seconds), but we expect to send a lot of quick reindexing jobs to DLC, so we need a more frequent job polling frequency per worker
    }

    pids = []
    count.times do
      ## Using Kernel.spawn and Process.detach because regular system() call would
      ## cause the processes to quit when capistrano finishes
      pid = spawn(env_vars, "rake resque:work", ops)
      Process.detach(pid)
      pids << pid
    end

    store_pids(pids, :append)
  end
end
