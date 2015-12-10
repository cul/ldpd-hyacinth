set :rails_env, "hyacinth_test"
set :application, "hyacinth_test"
set :domain,      "berlioz.cul.columbia.edu"
set :deploy_to,   "/opt/passenger/#{application}/"
set :user, "deployer"
set :scm_passphrase, "Current user can full owner domains."

role :app, domain
role :web, domain
role :db,  domain, primary: true
