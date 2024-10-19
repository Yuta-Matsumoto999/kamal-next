set :application, "production"
set :deploy_to, "/var/www/production"
server '160.251.234.214', user: 'deploy', roles: %w{app db web}