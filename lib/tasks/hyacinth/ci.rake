FEDORA_JETTY_ZIP_BASENAME = 'hyacinth-fedora-3.8.1-no-solr'.freeze


namespace :hyacinth do
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:rspec) do |spec|
    # INCLUDE_HYACINTH_SPECS is expected to be set (or not) by a wrapping task
    excepts = ['fedora', 'solr'] - ENV['INCLUDE_HYACINTH_SPECS'].to_s.split(',')

    spec.rspec_opts = excepts.map {| except| "--tag ~@#{except}" }
    spec.rspec_opts << '--backtrace' if ENV['CI']
  end

  require 'rubocop/rake_task'
  desc 'Run style checker'
  RuboCop::RakeTask.new(:rubocop) do |task|
    task.requires << 'rubocop-rspec'
    task.fail_on_error = true
  end

  desc 'CI build without rubocop'
  task ci_nocop: [:environment, 'hyacinth:ci_specs']

  desc 'CI build with Rubocop validation'
  task ci: [:environment, 'hyacinth:rubocop', 'hyacinth:ci_specs']

  require 'solr_wrapper/rake_task'
  desc 'CI build just running specs'
  task ci_specs: :environment do
    includes = ['fedora', 'solr'] - ENV['EXCEPT'].to_s.split(',')
    ENV['INCLUDE_HYACINTH_SPECS'] = includes.join(',')
    rspec_system_exit_failure_exception = nil

    task_stack = ['hyacinth:rspec']
    task_stack.unshift('hyacinth:solr_wrapper') if includes.include?('solr')
    task_stack.unshift('hyacinth:fedora_wrapper') if includes.include?('fedora')
    duration = Benchmark.realtime do
      ENV['RAILS_ENV'] = 'test'
      Rails.env = ENV['RAILS_ENV']

      puts "setting up test db...\n"
      Rake::Task['db:environment:set'].invoke
      Rake::Task['db:drop'].invoke
      Rake::Task['db:create'].invoke
      Rake::Task['db:migrate'].invoke
      begin
        Rake::Task[task_stack.shift].invoke(task_stack)
      rescue SystemExit => e
        rspec_system_exit_failure_exception = e
      end
    end
    puts "\nCI run finished in #{duration} seconds."
    # Re-raise caught exit exception (if present) AFTER solr shutdown and CI duration display.
    # This exception triggers an exit call with the original error code sent out by rspec failure.
    raise rspec_system_exit_failure_exception unless rspec_system_exit_failure_exception.nil?
  end

  task :solr_wrapper, [:task_stack] => [:environment] do |task, args|
    rspec_system_exit_failure_exception = nil
    task_stack = args[:task_stack]
    solr_unpack_dir = Rails.root.join('tmp', 'solr')
    solr_download_dir = Rails.root.join('tmp', 'solr-download')

    if File.exist?(solr_unpack_dir)
      # Delete old solr if it exists because we want a fresh solr instance
      puts "Deleting old test solr instance at #{solr_unpack_dir}...\n"
      FileUtils.rm_rf(solr_unpack_dir)
    end

    puts "Unzipping and starting new solr instance...\n"
    SolrWrapper.wrap(version: '6.3.0', port: 8984, instance_dir: solr_unpack_dir, download_dir: solr_download_dir) do |solr_wrapper_instance|
      # Create collection
      solr_wrapper_instance.with_collection(name: 'hyacinth-solr', dir: Rails.root.join('spec', 'fixtures', 'solr_cores', 'hyacinth-solr-6-3', 'conf')) do
        begin
          Rake::Task[task_stack.shift].invoke(task_stack)
        rescue SystemExit => e
          rspec_system_exit_failure_exception = e
        end
      end
      print 'Stopping solr...'
    end
    puts 'stopped.'
  end

  task :fedora_wrapper, [:task_stack] => [:environment] do |task, args|
    rspec_system_exit_failure_exception = nil
    task_stack = args[:task_stack]
    puts "Starting fedora wrapper...\n"
    require 'jettywrapper'
    Jettywrapper.url = "https://github.com/cul/hydra-jetty/archive/#{FEDORA_JETTY_ZIP_BASENAME}.zip"
    Rake::Task['jetty:clean'].invoke
    rspec_system_exit_failure_exception = Jettywrapper.wrap(Rails.application.config_for(:jetty).symbolize_keys) do
      print "Starting fedora\n...#{Rails.application.config_for(:jetty)}\n"
      Rake::Task[task_stack.shift].invoke(task_stack)
      print 'Stopping fedora...'
    end
    raise rspec_system_exit_failure_exception if rspec_system_exit_failure_exception
  end
rescue LoadError => e
  # Be prepared to rescue so that this rake file can exist in environments where RSpec is unavailable (i.e. production environments).
  puts '[Warning] Exception creating ci/rubocop/rspec rake tasks. '\
    'This message can be ignored in environments that intentionally do not pull in certain development/test environment gems (i.e. production environments).'
  puts e
end
