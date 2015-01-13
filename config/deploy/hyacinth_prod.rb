set :rails_env, "hyacinth_prod"
set :application, "hyacinth_prod"
set :domain,      "rossini.cul.columbia.edu"
set :deploy_to,   "/opt/passenger/#{application}/"
set :user, "deployer"
set :scm_passphrase, "Current user can full owner domains."

role :app, domain
role :web, domain
role :db,  domain, :primary => true
