set :default_stage, "hyacinth_dev"
set :stages, %w(hyacinth_dev hyacinth_test hyacinth_prod)

require 'capistrano/ext/multistage'
require 'bundler/capistrano'
require 'date'

default_run_options[:pty] = true

set :application, "hyacinth"
set :branch do
  default_tag = `git tag`.split("\n").last

  tag = Capistrano::CLI.ui.ask "Tag to deploy (make sure to push the tag first): [#{default_tag}] "
  tag = default_tag if tag.empty?
  tag
end

set :scm, :git
set :git_enable_submodules, 1
set :deploy_via, :remote_cache
set :repository,  "git@github.com:cul/hyacinth.git"
set :use_sudo, false

# Note: The line below is meaningless. It's just a workaround for Rails 4.0 because
# in 4.0, initializers and the database configuration are always loaded before
# precompiling assets.  This doesn't work for us because we add the database symlink
# at the end.  Maybe later, we'll see if we can just set up the database symlink earlier
# in the deploy process, but hopefully this will work as a fix for now.
# See: https://iprog.com/posting/2013/07/errors-when-precompiling-assets-in-rails-4-0
set :asset_env, "RAILS_GROUPS=assets DATABASE_URL=mysql2://user:pass@127.0.0.1/dbname"

namespace :deploy do
  desc "Add tag based on current version"
  task :auto_tag, :roles => :app do
    current_version = 'v' +
                      IO.read("VERSION").strip +
                      "/" +
                      DateTime.now.strftime("%Y%m%d")
    tag = Capistrano::CLI.ui.ask "Tag to add: [#{current_version}] "
    tag = current_version if tag.empty?

    system("git tag -a #{tag} -m 'auto-tagged' && git push origin --tags")
  end

  desc "Restart Application"
  task :restart, :roles => :app do
    run "mkdir -p #{current_path}/tmp/cookies"
    run "touch #{current_path}/tmp/restart.txt"
  end

  task :symlink_shared do
    run "ln -nfs #{deploy_to}shared/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{deploy_to}shared/fedora.yml #{release_path}/config/fedora.yml"
    run "ln -nfs #{deploy_to}shared/hyacinth.yml #{release_path}/config/hyacinth.yml"
    run "ln -nfs #{deploy_to}shared/secrets.yml #{release_path}/config/secrets.yml"
    run "ln -nfs #{deploy_to}shared/solr.yml #{release_path}/config/solr.yml"

    run "mkdir -p #{release_path}/db"
    run "ln -nfs #{deploy_to}shared/#{rails_env}.sqlite3 #{release_path}/db/#{rails_env}.sqlite3"
  end


  desc "Compile assets"
  task :assets do
    run "cd #{release_path}; RAILS_ENV=#{rails_env} bundle exec rake assets:clean assets:precompile"
  end

end



after 'deploy:update_code', 'deploy:symlink_shared'
before "deploy:create_symlink", "deploy:assets"
