source :rubygems
gem "rails", "2.3.5"
gem "ruby-openid", "~> 2.1.4", :require => "openid"

platforms :ruby do
  gem "mysql"
end
platforms :jruby do
  gem "activerecord-jdbc-adapter", :require => false
end

gem "devise", "~> 1.0.8"
gem "devise_cas_authenticatable", ">= 1.0.0.alpha8"
gem "json"
gem "ae_users_migrator", ">= 1.0.4"
gem "cancan"

gem "acts_as_singleton"
gem "ruby-graphviz", ">= 0.9.2", :require => "graphviz"
gem "radius"
gem "nbudin-version_fu", :require => "version_fu"
gem "jrails"
gem "rubyzip"
gem "nokogiri", ">= 1.4.1"
gem "sanitize"
gem "heroku_external_db"
gem "illyan_client", ">= 1.0.2"

group :development do
end

group :test do
  gem 'database_cleaner'
  gem 'shoulda'
  gem 'factory_girl', "~> 1.2.3"
  gem 'launchy'
  gem 'capybara'
  gem 'cucumber'
  gem 'cucumber-rails'
  gem 'sham_rack'
  gem 'castronaut', :git => 'http://github.com/nbudin/castronaut.git', :branch => 'dam5s-merge'
end
