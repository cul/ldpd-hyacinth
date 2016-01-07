# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'hyacinth'
set :repo_url, 'git@github.com:cul/hyacinth.git'

# Default branch is :master
#ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp # Current branch is suggested by default
ask :branch, proc { `git tag --sort=version:refname`.split("\n").last } # Latest tag is suggested by default

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug
set :log_level, :info

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')
set :linked_files, fetch(:linked_files, []).push(
  'config/database.yml',
  'config/fedora.yml',
  'config/hyacinth.yml',
  'config/repository_cache.yml',
  'config/resque.yml',
  'config/secrets.yml',
  'config/solr.yml',
  'config/term_additional_fields.yml',
  'config/uri_service.yml'
)

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')
set :linked_dirs, fetch(:linked_dirs, []).push('log')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }
# set :default_env, { path: "/opt/ruby/ruby-2.2.2/bin/ruby:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 3

# This is for 'passenger-config restart-app', which
# isn't working anyway.
# # Capistrano can't find passenger:
# #   ERROR: Phusion Passenger doesn't seem to be running
# # So tell it where we it's installed:
# #   https://github.com/capistrano/passenger/blob/master/README.md
# set :passenger_environment_variables, { :path => '$PATH:/opt/nginx/passenger/passenger-5.0.7/bin' }

# can't get "passenger-config restart-app" working
set :passenger_restart_with_touch, true

namespace :deploy do
  
  desc "Add tag based on current version"
  task :auto_tag do
    current_version_and_yyymmd_tag = "v" + IO.read("VERSION").to_s.strip + "/" + Date.today.strftime("%Y%m%d")
    tag = ask(:'tag', current_version_and_yyymmd_tag)
    tag = fetch(:tag)

    system("git tag -a #{tag} -m 'auto-tagged' && git push origin --tags")
  end

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
      
      #execute :rake, 'cache:clear'
      
    end
  end

end
