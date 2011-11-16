source "http://rubygems.org"
gem "rails", "3.1.1"
gem "json"
gem "sass"
gem 'coffee-script'
gem 'uglifier'

platforms :ruby do
  gem "mysql2"
end
platforms :jruby do
  gem "activerecord-jdbc-adapter", :require => false
end

gem 'ruby-debug',   :groups => [:development, :test], :platform => :ruby_18
gem 'ruby-debug19', :groups => [:development, :test], :platform => :ruby_19, :require => 'ruby-debug'

gem "devise", "~> 1.4.0"
gem "devise_cas_authenticatable", :git => "http://github.com/nbudin/devise_cas_authenticatable.git"
gem "ae_users_migrator", ">= 1.0.4"
gem "cancan"

gem "acts_as_list"
gem "ruby-graphviz", ">= 0.9.2", :require => "graphviz"
gem "radius"
gem "version_fu", "~> 1.0.1"
gem "jquery-rails", '>= 1.0.12'
gem "rubyzip"
gem "nokogiri", ">= 1.4.1"
gem "sanitize", "~> 2.0.2"
gem "heroku_external_db"
gem "illyan_client", ">= 1.0.2"
gem "hoptoad_notifier"
gem "sqlite3", :groups => [:development, :test]

group :development do
  gem "thin"
end

group :test do
  gem 'database_cleaner'
  gem 'shoulda'
  gem 'factory_girl_rails'
  gem 'launchy'
  gem 'capybara'
  gem 'capybara-webkit'
  gem 'cucumber'
  gem 'cucumber-rails'
  gem 'sham_rack'
  gem 'minitest'
  gem 'castronaut', :git => 'http://github.com/nbudin/castronaut.git', :branch => 'dam5s-merge'
  gem 'turn', :require => false
end
