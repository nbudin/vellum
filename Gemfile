source "http://rubygems.org"
gem "rails", "3.1.0.rc1"
gem "rake", "~> 0.8.7"
gem "json"
gem "sass"
gem 'coffee-script'
gem 'uglifier'

platforms :ruby do
  gem "mysql"
end
platforms :jruby do
  gem "activerecord-jdbc-adapter", :require => false
end

gem "devise", "~> 1.3.0"
gem "devise_cas_authenticatable", ">= 1.0.0.alpha8"
gem "ae_users_migrator", ">= 1.0.4"
gem "cancan"

gem "ruby-graphviz", ">= 0.9.2", :require => "graphviz"
gem "radius"
gem "version_fu", "~> 1.0.1"
gem "jquery-rails"
gem "rubyzip"
gem "nokogiri", ">= 1.4.1"
gem "sanitize", "~> 2.0.2"
gem "heroku_external_db"
gem "illyan_client", ">= 1.0.2"
gem "hoptoad_notifier"

group :development do
  gem "thin"
end

group :test do
  gem 'database_cleaner'
  gem 'shoulda'
  gem 'factory_girl_rails'
  gem 'launchy'
  gem 'capybara'
  gem 'cucumber'
  gem 'cucumber-rails'
  gem 'sham_rack'
  gem 'castronaut', :git => 'http://github.com/nbudin/castronaut.git', :branch => 'dam5s-merge'
  gem 'turn', :require => false
end
