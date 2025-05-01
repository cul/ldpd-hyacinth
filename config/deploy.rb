# frozen_string_literal: true

# config valid for current version and patch releases of Capistrano
lock '~> 3.18.0'

# Until we retire all old CentOS VMs, we need to set the rvm_custom_path because rvm is installed
# in a non-standard location for our AlmaLinux VMs.  This is because our service accounts need to
# maintain two rvm installations for two different Linux OS versions.
set :rvm_custom_path, '~/.rvm-alma8'

set :remote_user, 'ldpdserv'
set :application, 'hyacinth_2'
set :repo_url, "git@github.com:cul/ldpd-hyacinth.git"
set :deploy_name, "#{fetch(:application)}_#{fetch(:stage)}"
# used to run rake db:migrate, etc
set :rails_env, fetch(:deploy_name)

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/opt/passenger/#{fetch(:deploy_name)}"

# Default value for :linked_files is []
append  :linked_files,
        'config/aws.yml',
        'config/gcp.yml',
        'config/master.key',
        'config/database.yml',
        'config/datacite.yml',
        'config/fedora.yml',
        'config/hyacinth.yml',
        'config/image_server.yml',
        'config/derivative_server.yml',
        'config/redis.yml',
        'config/resque.yml',
        'config/solr.yml',
        'config/term_additional_fields.yml',
        'config/uri_service.yml',
        'config/ezid.yml'

# Default value for linked_dirs is []
append :linked_dirs, 'log', 'tmp/pids', 'node_modules'

set :passenger_restart_with_touch, true

# Default value for keep_releases is 5
set :keep_releases, 3

# Set default log level (which can be overridden by other environments)
set :log_level, :info

# NVM Setup, for selecting the correct node version
# NOTE: This NVM configuration MUST be configured before the RVM setup steps because:
# This works:
# nvm exec 16 ~/.rvm-alma8/bin/rvm example_app_dev do node --version
# But this does not work:
# ~/.rvm-alma8/bin/rvm example_app_dev do nvm exec 16 node --version
set :nvm_node_version, fetch(:deploy_name) # This NVM alias must exist on the server
[:rake, :node, :npm, :yarn].each do |command_to_prefix|
  SSHKit.config.command_map.prefix[command_to_prefix].push("nvm exec #{fetch(:nvm_node_version)}")
end

# RVM Setup, for selecting the correct ruby version (instead of capistrano-rvm gem)
set :rvm_ruby_version, fetch(:deploy_name) # This RVM alias must exist on the server
[:rake, :gem, :bundle, :ruby].each do |command_to_prefix|
  SSHKit.config.command_map.prefix[command_to_prefix].push(
    "#{fetch(:rvm_custom_path, '~/.rvm')}/bin/rvm #{fetch(:rvm_ruby_version)} do"
  )
end

# Default value for default_env is {}
set :default_env, NODE_ENV: 'production'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :airbrussh
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

after 'deploy:finished', 'hyacinth:restart_resque_workers'

namespace :hyacinth do
  desc 'Restart the resque workers'
  task :restart_resque_workers do
    on roles(:web) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          resque_restart_err_and_out_log = './log/resque_restart_err_and_out.log'
          # With Ruby > 3.0, we need to redirect stdout and stderr to a file, otherwise
          # capistrano hangs on this task (waiting for more output).
          execute :rake, 'resque:restart_workers', '>', resque_restart_err_and_out_log, '2>&1'
          # Show the restart log output
          execute :cat, resque_restart_err_and_out_log
        end
      end
    end
  end
end
