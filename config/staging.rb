set :application, "staging"
set :deploy_to, "/var/www/staging"
server '160.251.234.214', user: 'deploy', roles: %w{app db web}
