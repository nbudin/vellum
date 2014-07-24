source "http://rubygems.org"
ruby "2.1.2"

gem "rails", "3.2.18"
gem 'sprockets-rails', '=2.0.0.backport1'
gem 'sprockets', '=2.2.2.backport2'
gem 'sass-rails', github: 'guilleiguaran/sass-rails', branch: 'backport'
gem 'coffee-rails', "~> 3.2.1"
gem 'uglifier', ">= 1.0.3"
gem 'bootstrap-sass'
gem 'bower-rails'

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

gem "devise", "~> 2.0.5"
gem "devise_cas_authenticatable"
gem "ae_users_migrator", ">= 1.0.4"
gem "cancan"

gem "acts_as_list"
gem "ruby-graphviz", ">= 0.9.2", :require => "graphviz"
gem "radius"
gem "version_fu", "~> 1.0.1"
gem "jquery-rails", '>= 1.0.12'
gem 'jquery-ui-rails'
gem "rubyzip", ">= 1.0.0", :require => "zip"
gem "nokogiri", ">= 1.4.1"
gem "sanitize", "~> 2.0.2"
gem "heroku_external_db"
gem "illyan_client", ">= 1.0.2"
gem "rollbar"
gem "pry-rails", :groups => [:development, :test]
gem "rubypants", ">= 0.3.0", github: 'jmcnevin/rubypants'

gem "puma"
gem "asset_sync"

group :test do
  gem 'database_cleaner', '~> 1.0.0'  # 1.1.0 is broken on sqlite3, see https://github.com/bmabey/database_cleaner/issues/224
  gem 'shoulda', '~> 3.2.0'
  gem 'factory_girl_rails'
  gem 'launchy'
  gem 'capybara'
  gem 'poltergeist'
end
