set :deploy_to, "/var/www/vellum.aegames.org"

role :app, "ishinabe.natbudin.com"
role :web, "ishinabe.natbudin.com"
role :db,  "ishinabe.natbudin.com", :primary => true
