require 'bundler/capistrano'

set :application, "vellum"
set :repository,  "git://github.com/nbudin/vellum.git"

set :deploy_to, "/var/www/vellum.aegames.org"

role :app, "ishinabe.natbudin.com"
role :web, "ishinabe.natbudin.com"
role :db,  "ishinabe.natbudin.com", :primary => true

set :checkout, "export"
set :user, "www-data"
set :scm, "git"
set :use_sudo, false
set :deploy_via, :remote_cache
set :git_enable_submodules, 1

namespace :deploy do
  desc "Tell Passenger to restart this app"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
end
