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

namespace :bundler do
  task :create_symlink, :roles => :app do
    shared_dir = File.join(shared_path, 'bundle')
    release_dir = File.join(current_release, '.bundle')
    run("mkdir -p #{shared_dir} && ln -s #{shared_dir} #{release_dir}")
  end
  
  task :bundle_new_release, :roles => :app do
    bundler.create_symlink
    run "cd #{release_path} && bundle install --without test"
  end
  
  task :lock, :roles => :app do
    run "cd #{current_release} && bundle lock;"
  end
  
  task :unlock, :roles => :app do
    run "cd #{current_release} && bundle unlock;"
  end
end

namespace :deploy do
  desc "Tell Passenger to restart this app"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
end

# HOOKS
after "deploy:update_code" do
  bundler.bundle_new_release
  run "ln -nfs #{deploy_to}/#{shared_dir}/config/database.yml #{release_path}/config/database.yml"
  run "rm -f #{release_path}/config/newrelic.yml"
  run "ln -nfs #{deploy_to}/#{shared_dir}/config/newrelic.yml #{release_path}/config/newrelic.yml"
end