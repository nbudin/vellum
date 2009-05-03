set :application, "vellum"
set :repository,  "git://github.com/nbudin/vellum.git"

set :deploy_to, "/var/www/vellum.aegames.org"

role :app, "sakai.natbudin.com"
role :web, "sakai.natbudin.com"
role :db,  "sakai.natbudin.com", :primary => true

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

  desc "Link in database config"
  task :after_update_code do
    run "ln -nfs #{deploy_to}/#{shared_dir}/config/database.yml #{release_path}/config/database.yml"
  end
end
