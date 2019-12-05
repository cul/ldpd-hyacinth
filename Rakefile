# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

begin
  require 'jettywrapper'
  Jettywrapper.url = "https://github.com/cul/hydra-jetty/archive/hyacinth-fedora-3.8.1-no-solr.zip"

  SolrWrapper.default_instance_options = Rails.application.config_for(:solr_wrapper).deep_symbolize_keys
  require 'solr_wrapper/rake_task'

  task(:default).clear
  task default: ['hyacinth:ci']
rescue LoadError
  puts 'No jettywrapper, rspec or rubocop avaiable.'
  puts 'This is expected in production environments.'
end
