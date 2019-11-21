# frozen_string_literal: true

# Set up solr_wrapper so that it creates the hyacinth-development core if it
# doesn't already exist.

namespace :solr do
  task :after_start do
    core_dir = File.join(SolrWrapper.default_instance_options[:instance_dir], 'server', 'solr', 'hyacinth-development')
    unless File.exist?(core_dir)
      puts 'Creating hyacinth-development solr core...'
      FileUtils.mkdir_p(core_dir)
      FileUtils.cp_r(SolrWrapper.default_instance_options[:collection]['dir'], File.join(core_dir, 'conf'))
      File.write(File.join(core_dir, 'core.properties'), 'name=hyacinth-development')
      # Restart solr
      Rake::Task['solr:restart'].invoke
    end
  end

  # After hook that runs after existing solr:start task from solr_wrapper.
  # For more information: https://coderwall.com/p/qhdhgw/adding-a-post-execution-hook-to-the-rails-db-migrate-task
  task :start do
    Rake::Task['solr:after_start'].invoke
  end
end
