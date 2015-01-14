# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Hyacinth::Application.load_tasks

#require 'rake/clean'
#require 'rubygems'
#require 'bundler'
#require 'bundler/setup'
#
#Bundler::GemHelper.install_tasks
#require File.expand_path('../config/application', __FILE__)
#
##spec = Gem::Specification.find_by_name 'cul_scv_hydra'
##Dir.glob("#{spec.gem_dir}/lib/tasks/**/*.rake").each do |rakefile|
##  load rakefile
##end
##Dir.glob("lib/tasks/**/*.rake").each do |rakefile|
##  load rakefile
##end
#
#CLEAN.include %w[tmp *.log *.tmp]
#
##Hyacinth::Application.initialize_tasks
#task :ci => ['hyacinth:ci']
#task :spec => ['hyacinth:rspec']
#task :default => :ci
