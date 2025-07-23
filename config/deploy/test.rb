server 'hy-rails-test1.cul.columbia.edu', user: fetch(:remote_user), roles: %w[app db web]
# In test/prod, deploy from release tags; most recent version is default
ask :branch, proc { `git tag --sort=-creatordate | head -n 1`.split("\n").last }
