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
  require 'rubocop/cul'
  desc 'Run style checker'
  RuboCop::RakeTask.new(:rubocop) do |t|
    t.options = ['--display-cop-names']
    t.fail_on_error = true
  end

  desc 'CI build without rubocop'
  task ci_nocop: ['hyacinth:setup:config_files', 'hyacinth:docker:setup_config_files', :environment, 'hyacinth:ci_specs']

  desc 'CI build with Rubocop validation'
  task ci: ['hyacinth:setup:config_files', 'hyacinth:docker:setup_config_files', :environment, 'hyacinth:rubocop', 'hyacinth:ci_specs']

  desc 'CI build just running specs'
  task ci_specs: :environment do
    includes = ['fedora', 'solr'] - ENV['EXCEPT'].to_s.split(',')
    ENV['INCLUDE_HYACINTH_SPECS'] = includes.join(',')
    rspec_system_exit_failure_exception = nil

    task_stack = ['hyacinth:rspec']
    task_stack.prepend('hyacinth:docker_wrapper') if (includes & ['solr', 'fedora']).present?

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
      Rake::Task['hyacinth:languages:load_default_subtags'].invoke
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

  task :docker_wrapper, [:task_stack] => [:environment] do |task, args|
    unless Rails.env.test?
      raise 'This task should only be run in the test environment (because it clears docker volumes)'
    end

    task_stack = args[:task_stack]

    # stop docker if it's currently running (so we can delete any old volumes)
    Rake::Task['hyacinth:docker:stop'].invoke
    # rake tasks must be re-enabled if you want to call them again later during the same run
    Rake::Task['hyacinth:docker:stop'].reenable

    ENV['rails_env_confirmation'] = Rails.env # setting this to skip prompt in volume deletion task
    Rake::Task['hyacinth:docker:delete_volumes'].invoke

    Rake::Task['hyacinth:docker:start'].invoke
    begin
      Rake::Task[task_stack.shift].invoke(task_stack) while task_stack.present?
    rescue SystemExit => e
      rspec_system_exit_failure_exception = e
    end
    Rake::Task['hyacinth:docker:stop'].invoke
    raise rspec_system_exit_failure_exception if rspec_system_exit_failure_exception
  end
rescue LoadError => e
  # Be prepared to rescue so that this rake file can exist in environments where RSpec is unavailable (i.e. production environments).
  puts '[Warning] Exception creating ci/rubocop/rspec rake tasks. '\
    'This message can be ignored in environments that intentionally do not pull in certain development/test environment gems (i.e. production environments).'
  puts e
end
