server 'ldpd-nginx-test1.cul.columbia.edu', user: 'ldpdserv', roles: %w{app db web}
set :deploy_to, '/opt/passenger/ldpd/hyacinth_test'