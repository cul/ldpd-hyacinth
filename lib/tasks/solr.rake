# frozen_string_literal: true

# Set up solr_wrapper so that it creates the configured solr cores
# if they don't already exist.

namespace :solr do
  task :after_start do
    solr_config = SolrWrapper.default_instance_options

    restart_required = false

    solr_config[:collection].each do |core_config|
      core_name = core_config[:name]
      core_dir = core_config[:dir]
      core_instance_dir = File.join(solr_config[:instance_dir], 'server', 'solr', core_name)

      next if File.exist?(core_instance_dir)

      puts Rainbow("Creating #{core_name} solr core at #{core_instance_dir}...").green
      FileUtils.mkdir_p(core_instance_dir)
      FileUtils.cp_r(core_dir, File.join(core_instance_dir, 'conf'))
      File.write(File.join(core_instance_dir, 'core.properties'), "name=#{core_name}")
      restart_required = true
    end

    Rake::Task['solr:restart'].invoke if restart_required # Restart solr
  end

  # After hook that runs after existing solr:start task from solr_wrapper.
  # For more information: https://coderwall.com/p/qhdhgw/adding-a-post-execution-hook-to-the-rails-db-migrate-task
  task :start do
    at_exit do
      Rake::Task['solr:after_start'].invoke
    end
  end
end
