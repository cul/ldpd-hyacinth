require "active-fedora"

# NOTE: We don't run the ci task in production environments
if ['development', 'test'].include?(Rails.env)
  namespace :hyacinth do
    require 'rspec/core/rake_task'
    RSpec::Core::RakeTask.new(:rspec) do |spec|
      spec.pattern = FileList['spec/**/*_spec.rb']
      spec.pattern += FileList['spec/*_spec.rb']
      spec.rspec_opts = ['--backtrace'] if ENV['CI']
    end

    RSpec::Core::RakeTask.new(:rcov) do |spec|
      spec.pattern = FileList['spec/**/*_spec.rb']
      spec.pattern += FileList['spec/*_spec.rb']
      spec.rcov = true
    end

    require 'rubocop/rake_task'
    desc 'Run style checker'
    RuboCop::RakeTask.new(:rubocop) do |task|
      task.requires << 'rubocop-rspec'
      task.fail_on_error = true
    end

    desc 'Set rails environment to "test"'
    task :set_rails_test_environment do
      ENV['RAILS_ENV'] = 'test'
      Rails.env = ENV['RAILS_ENV']
    end

    desc 'CI build without rubocop'
    task ci_nocop: ['hyacinth:set_rails_test_environment', 'hyacinth:setup:config_files', 'hyacinth:docker:setup_config_files', :environment, 'hyacinth:ci_specs']

    desc 'CI build with Rubocop validation'
    task ci: ['hyacinth:set_rails_test_environment', 'hyacinth:setup:config_files', 'hyacinth:docker:setup_config_files', :environment, 'hyacinth:rubocop', 'hyacinth:ci_specs']

    desc 'CI build just running specs'
    task ci_specs: :environment do
      docker_wrapper do
        duration = Benchmark.realtime do
          Rake::Task["hyacinth:fedora:reload_cmodels"].invoke
          Rake::Task["uri_service:db:drop_tables_and_clear_solr"].invoke
          Rake::Task["hyacinth:test:clear_local_default_resource_storage_content"].invoke
          Rake::Task["uri_service:db:setup"].invoke
          Rake::Task['db:environment:set'].invoke
          Rake::Task['db:drop'].invoke
          Rake::Task['db:create'].invoke
          Rake::Task['db:migrate'].invoke
          Rake::Task["hyacinth:setup:core_records"].invoke
          ENV['CLEAR'] = 'true' # Set ENV variable for reindex task
          Rake::Task['hyacinth:index:reindex'].invoke
          ENV['CLEAR'] = nil  # Clear ENV variable because we're done with it
          Rake::Task['hyacinth:test:setup_test_project'].invoke
          Rake::Task['hyacinth:rspec'].invoke
        end
        puts "\nCI run finished in #{duration} seconds."
      end
    end

    def docker_wrapper(&block)
      unless Rails.env.test?
        raise 'This task should only be run in the test environment (because it clears docker volumes)'
      end

      # Stop docker if it's currently running (so we can delete any old volumes)
      Rake::Task['hyacinth:docker:stop'].invoke
      # Rake tasks must be re-enabled if you want to call them again later during the same run
      Rake::Task['hyacinth:docker:stop'].reenable

      ENV['rails_env_confirmation'] = Rails.env # setting this to skip prompt in volume deletion task
      Rake::Task['hyacinth:docker:delete_volumes'].invoke

      Rake::Task['hyacinth:docker:start'].invoke
      begin
        block.call
      ensure
        Rake::Task['hyacinth:docker:stop'].invoke
      end
    end
  end
end
