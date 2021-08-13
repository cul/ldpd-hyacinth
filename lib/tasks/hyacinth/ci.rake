# frozen_string_literal: true

namespace :hyacinth do
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:rspec) do |spec|
    # INCLUDE_HYACINTH_SPECS is expected to be set (or not) by a wrapping task
    excepts = ['fedora', 'solr'] - ENV['INCLUDE_HYACINTH_SPECS'].to_s.split(',')

    spec.rspec_opts = excepts.map { |except| "--tag ~@#{except}" }
    spec.rspec_opts << '--backtrace' if ENV['CI']
  end

  require 'rubocop/rake_task'
  desc 'Run style checker'
  RuboCop::RakeTask.new(:rubocop) do |task|
    task.requires << 'rubocop-rspec'
    task.fail_on_error = true
  end

  desc 'CI build without rubocop'
  task ci_nocop: ['hyacinth:setup:config_files', :environment, 'hyacinth:ci_specs']

  desc 'CI build with Rubocop validation'
  task ci: ['hyacinth:setup:config_files', :environment, 'hyacinth:rubocop', 'hyacinth:ci_specs']

  desc 'CI build just running specs'
  task ci_specs: :environment do
    includes = ['fedora', 'solr'] - ENV['EXCEPT'].to_s.split(',')
    ENV['INCLUDE_HYACINTH_SPECS'] = includes.join(',')
    rspec_system_exit_failure_exception = nil

    task_stack = ['hyacinth:rspec']
    task_stack.prepend('hyacinth:solr_wrapper') if includes.include?('solr')
    task_stack.prepend('hyacinth:fedora_wrapper') if includes.include?('fedora')

    duration = Benchmark.realtime do
      ENV['RAILS_ENV'] = 'test'
      Rails.env = ENV['RAILS_ENV']

      # A webpacker recompile isn't strictly required, but it speeds up the first feature test run and
      # can prevent first feature test timeout issues, especially in a slower CI server environment.
      if ENV['WEBPACKER_RECOMPILE'] == 'true'
        puts 'Recompiling pack...'
        recompile_duration = Benchmark.realtime do
          Rake::Task['webpacker:compile'].invoke
        end
        puts "Done recompiling pack.  Took #{recompile_duration} seconds."
      end

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
    solr_wrapper_config = Rails.application.config_for(:solr_wrapper).deep_symbolize_keys

    if File.exist?(solr_wrapper_config[:instance_dir])
      # Delete old solr if it exists because we want a fresh solr instance
      puts "Deleting old test solr instance at #{solr_wrapper_config[:instance_dir]}...\n"
      FileUtils.rm_rf(solr_wrapper_config[:instance_dir])
    end

    puts "Unzipping and starting new solr instance...\n"
    SolrWrapper.wrap(solr_wrapper_config) do |solr_wrapper_instance|
      # Create collections
      # create is stricter about solr options being in [c,d,n,p,shards,replicationFactor]
      original_solr_options = solr_wrapper_instance.config.static_config.options[:solr_options].dup
      allowed_create_options = [:c, :d, :n, :p, :shards, :replicationFactor]
      solr_wrapper_instance.config.static_config.options[:solr_options]&.delete_if { |k, v| !allowed_create_options.include?(k) }
      solr_wrapper_config[:collection].each do |c|
        solr_wrapper_instance.create(c)
      end
      solr_wrapper_instance.config.static_config.options[:solr_options] = original_solr_options
      begin
        Rake::Task[task_stack.shift].invoke(task_stack)
      rescue SystemExit => e
        rspec_system_exit_failure_exception = e
      end

      print 'Stopping solr...'
    end
    puts 'stopped.'
    raise rspec_system_exit_failure_exception if rspec_system_exit_failure_exception
  end

  task :fedora_wrapper, [:task_stack] => [:environment] do |task, args|
    rspec_system_exit_failure_exception = nil
    task_stack = args[:task_stack]

    Jettywrapper.jetty_dir = Rails.root.join('tmp', 'jetty-test').to_s

    puts "Starting fedora wrapper...\n"
    Rake::Task['jetty:clean'].invoke
    rspec_system_exit_failure_exception = Jettywrapper.wrap(Rails.application.config_for(:jetty).symbolize_keys.merge({ jetty_home: Jettywrapper.jetty_dir })) do
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
