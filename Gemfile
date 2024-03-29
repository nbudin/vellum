source "https://rubygems.org"
ruby File.read(File.expand_path('../.ruby-version', __FILE__)).strip

gem "rails", "4.2.11.3"
gem 'sass-rails'
gem 'coffee-rails'
gem 'uglifier', ">= 1.0.3"
gem 'bootstrap-sass'
gem 'bootstrap-wysihtml5-rails'
gem 'bower-rails'
gem 'figaro'

gem "pg", '~> 0.15'
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
gem "jquery-rails", '~> 4.4.0'
gem 'jquery-ui-rails'
gem "rubyzip", "~> 2.0.0", :require => "zip"
gem "nokogiri", ">= 1.8.1"
gem "sanitize", "~> 6.0.0"
gem "heroku_external_db"
gem "illyan_client", "~> 2.0"
gem "rollbar"
gem "pry-rails", :groups => [:development, :test]
gem "rubypants", ">= 0.3.0", git: 'https://github.com/jmcnevin/rubypants.git'
gem 'webdrivers', groups: [:development, :test]

gem 'htmldiff-lcs', git: 'https://github.com/nbudin/htmldiff-lcs.git', require: 'htmldiff'

gem "puma"

# Not sure what's causing us to need this but we do apparently
gem 'xmlrpc'

group :test do
  gem 'database_cleaner'
  gem 'minitest', '< 5.19'  # minitest-spec-rails breaks because of the removal of the MiniTest alias
  gem 'minitest-spec-rails'
  gem 'minitest-matchers_vaccine'
  gem 'minitest-reporters'
  gem 'shoulda-matchers'
  gem 'factory_girl_rails'
  gem 'launchy'
  gem 'capybara'
  gem 'selenium-webdriver'
  gem "codeclimate-test-reporter", group: :test
end

group :development do
  gem 'capistrano'
  gem 'capistrano-rbenv'
  gem 'capistrano-rails'
  gem 'capistrano-maintenance', require: false
  gem 'ed25519'
  gem 'bcrypt_pbkdf'

  gem 'spring'
end
