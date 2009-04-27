set :application, "vellum"
set :repository,  "http://svn.aegames.org/svn/vellum"

set :deploy_to, "/var/www/vellum.aegames.org"

role :app, "sakai.natbudin.com"
role :web, "sakai.natbudin.com"
role :db,  "sakai.natbudin.com", :primary => true

set :checkout, "export"
set :user, "www-data"
set :scm, "subversion"

namespace :deploy do
  desc "Tell Passenger to restart this app"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
end
