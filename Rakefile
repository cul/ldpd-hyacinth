# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

require 'jettywrapper'
Jettywrapper.url = "https://github.com/cul/hydra-jetty/archive/hyacinth-fedora-3.8.1-no-solr.zip"

SolrWrapper.default_instance_options = Rails.application.config_for(:solr_wrapper).symbolize_keys
require 'solr_wrapper/rake_task'

Rails.application.load_tasks

task(:default).clear
task default: ['hyacinth:ci']
