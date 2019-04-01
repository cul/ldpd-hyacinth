namespace :hyacinth do
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:rspec) do |spec|
    spec.rspec_opts = []
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
    rspec_system_exit_failure_exception = nil

    duration = Benchmark.realtime do
      ENV['RAILS_ENV'] = 'test'
      Rails.env = ENV['RAILS_ENV']

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
          Rake::Task['db:environment:set'].invoke
          Rake::Task['db:drop'].invoke
          Rake::Task['db:create'].invoke
          Rake::Task['db:migrate'].invoke
          begin
            Rake::Task['hyacinth:rspec'].invoke
          rescue SystemExit => e
            rspec_system_exit_failure_exception = e
          end
        end
        print 'Stopping solr...'
      end
      puts 'stopped.'
    end
    puts "\nCI run finished in #{duration} seconds."
    # Re-raise caught exit exception (if present) AFTER solr shutdown and CI duration display.
    # This exception triggers an exit call with the original error code sent out by rspec failure.
    raise rspec_system_exit_failure_exception unless rspec_system_exit_failure_exception.nil?
  end
rescue LoadError => e
  # Be prepared to rescue so that this rake file can exist in environments where RSpec is unavailable (i.e. production environments).
  puts '[Warning] Exception creating ci/rubocop/rspec rake tasks. '\
    'This message can be ignored in environments that intentionally do not pull in certain development/test environment gems (i.e. production environments).'
  puts e
end
