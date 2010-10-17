set :deploy_to, "/var/www/vellumbeta.aegames.org"

role :app, "sakai.natbudin.com"
role :web, "sakai.natbudin.com"
role :db,  "sakai.natbudin.com", :primary => true

set :branch, "wymeditor"