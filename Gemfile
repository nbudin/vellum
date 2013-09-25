source "http://rubygems.org"
ruby "2.0.0"

gem "rails", "3.2.14"
gem "sass-rails", "~> 3.2.3"
gem 'coffee-rails', "~> 3.2.1"
gem 'uglifier', ">= 1.0.3"

group :production do
  platforms :ruby do
    gem "mysql2"
  end
  platforms :jruby do
    gem "activerecord-jdbc-adapter", :require => false
  end
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
gem "rubyzip"
gem "nokogiri", ">= 1.4.1"
gem "sanitize", "~> 2.0.2"
gem "heroku_external_db"
gem "illyan_client", ">= 1.0.2"
gem "airbrake"
gem "sqlite3", :groups => [:development, :test, :hangar]
gem "pry-rails", :groups => [:development, :test]
gem "farbtastic-rails"

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
