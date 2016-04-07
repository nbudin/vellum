source "http://rubygems.org"
ruby "2.1.2"

gem "rails", "4.2.6"
gem 'sass-rails'
gem 'coffee-rails'
gem 'uglifier', ">= 1.0.3"
gem 'bootstrap-sass'
gem 'bootstrap-wysihtml5-rails'
gem 'bower-rails'
gem 'figaro'

gem "pg"
# DISABLING rails_12factor BECAUSE IT'S PREVENTING production.log GETTING WRITTEN
# gem 'rails_12factor', group: :production
gem "sqlite3", :groups => [:development, :test]

gem "devise"
gem "devise_cas_authenticatable"
gem "ae_users_migrator", ">= 1.0.4"
gem "cancancan"
gem "haml"

gem "acts_as_list"
gem "ruby-graphviz", ">= 0.9.2", :require => "graphviz"
gem "radius"
gem "jquery-rails", '>= 1.0.12'
gem 'jquery-ui-rails'
gem "rubyzip", ">= 1.0.0", :require => "zip"
gem "nokogiri", ">= 1.4.1"
gem "sanitize", "~> 4.0.0"
gem "heroku_external_db"
gem "illyan_client", "~> 2.0"
gem "rollbar"
gem "pry-rails", :groups => [:development, :test]
gem "rubypants", ">= 0.3.0", github: 'jmcnevin/rubypants'

gem 'htmldiff-lcs', github: 'nbudin/htmldiff-lcs', require: 'htmldiff'

gem "puma"
gem "asset_sync"

group :test do
  gem 'database_cleaner'
  gem 'minitest-spec-rails'
  gem 'minitest-matchers_vaccine'
  gem 'minitest-reporters'
  gem 'shoulda-matchers'
  gem 'factory_girl_rails'
  gem 'launchy'
  gem 'capybara'
  gem 'poltergeist'
  gem "codeclimate-test-reporter", group: :test
end

group :development do
  gem 'capistrano'
  gem 'capistrano-rbenv'
  gem 'capistrano-rails'
  gem 'capistrano-maintenance', require: false

  gem 'spring'
end