source "http://rubygems.org"
ruby "2.1.2"

gem "rails", "4.2.4"
gem 'sass-rails'
gem 'coffee-rails'
gem 'uglifier', ">= 1.0.3"
gem 'bootstrap-sass'
gem 'bootstrap-wysihtml5-rails'
gem 'bower-rails'
gem 'figaro'

group :production do
  platforms :ruby do
    gem "mysql2"
  end
  platforms :jruby do
    gem "activerecord-jdbcmysql-adapter"
  end
  
  gem 'rails_12factor'
end

platform :ruby do
  gem "sqlite3", :groups => [:development, :test, :hangar]
end

platform :jruby do
  gem "activerecord-jdbc-adapter", require: false
  gem "activerecord-jdbcsqlite3-adapter", :groups => [:development, :test, :hangar]
end

gem "devise"
gem "devise_cas_authenticatable"
gem "ae_users_migrator", ">= 1.0.4"
gem "cancancan"

gem "acts_as_list"
gem "ruby-graphviz", ">= 0.9.2", :require => "graphviz"
gem "radius"
gem "jquery-rails", '>= 1.0.12'
gem 'jquery-ui-rails'
gem "rubyzip", ">= 1.0.0", :require => "zip"
gem "nokogiri", ">= 1.4.1"
gem "sanitize", "~> 4.0.0"
gem "heroku_external_db"
gem "illyan_client", ">= 1.0.2"
gem "rollbar"
gem "pry-rails", :groups => [:development, :test]
gem "rubypants", ">= 0.3.0", github: 'jmcnevin/rubypants'

gem "puma"
gem "asset_sync"

group :test do
  gem 'database_cleaner'
  gem 'minitest-spec-rails'
  gem 'minitest-matchers_vaccine'
  gem 'shoulda-matchers'
  gem 'factory_girl_rails'
  gem 'launchy'
  gem 'capybara'
  gem 'poltergeist'
end

group :development do
  gem 'capistrano'
  gem 'capistrano-rbenv'
  gem 'capistrano-rails'
  
  gem 'spring'
end