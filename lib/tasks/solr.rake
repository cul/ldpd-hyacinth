# frozen_string_literal: true

# Set up solr_wrapper so that it creates the configured solr cores
# if they don't already exist.

namespace :solr do
  task :after_start do
    solr_config = SolrWrapper.default_instance_options

    solr_config[:collection].each do |core_config|
      core_name = core_config[:name]
      core_dir = core_config[:dir]
      core_instance_dir = File.join(solr_config[:instance_dir], 'server', 'solr', core_name)

      unless File.exist?(core_instance_dir)
        puts "Creating #{core_name} solr core..."
        FileUtils.mkdir_p(core_instance_dir)
        FileUtils.cp_r(core_dir, File.join(core_instance_dir, 'conf'))
        File.write(File.join(core_instance_dir, 'core.properties'), "name=#{core_name}")
      end

      Rake::Task['solr:restart'].invoke # Restart solr
    end
  end

  # After hook that runs after existing solr:start task from solr_wrapper.
  # For more information: https://coderwall.com/p/qhdhgw/adding-a-post-execution-hook-to-the-rails-db-migrate-task
  task :start do
    Rake::Task['solr:after_start'].invoke
  end
end
