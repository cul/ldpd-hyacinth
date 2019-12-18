# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

begin
  require 'jettywrapper'
  Jettywrapper.url = "https://github.com/cul/hydra-jetty/archive/hyacinth-fedora-3.8.1-no-solr.zip"
  # ensure a solr_wrapper config is in place before attempting to set SolrWrapper.default_instance_options
  solr_wrapper_config_path = Rails.root.join('config', 'solr_wrapper.yml')
  unless File.exist?(solr_wrapper_config_path)
    src_path = Rails.root.join('config', 'templates', 'solr_wrapper.template.yml')
    FileUtils.cp(src_path, solr_wrapper_config_path)
  end
  SolrWrapper.default_instance_options = Rails.application.config_for(:solr_wrapper).deep_symbolize_keys
  require 'solr_wrapper/rake_task'

  task(:default).clear
  task default: ['hyacinth:ci']
rescue LoadError
  puts 'No jettywrapper, rspec or rubocop avaiable.'
  puts 'This is expected in production environments.'
end
