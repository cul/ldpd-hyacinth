server "#{fetch(:instance)}-nginx-#{fetch(:stage)}1.cul.columbia.edu", user: fetch(:remote_user), roles: %w(app db web)
# In test/prod, deploy from release tags; most recent version is default
ask :branch, proc { `git tag --sort=version:refname`.split("\n").last }
