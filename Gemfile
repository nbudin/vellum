source :rubygems
gem "rails", "2.3.5"
gem "ruby-openid", "~> 2.1.4", :require => "openid"

platforms :ruby do
  gem "mysql"
end
platforms :jruby do
  gem "activerecord-jdbc-adapter", :require => false
end

gem "acts_as_singleton"
gem "ruby-graphviz", ">= 0.9.2", :require => "graphviz"
gem "radius"
gem "nbudin-version_fu", :require => "version_fu"
gem "jrails"
gem "rubyzip"
gem "nokogiri", ">= 1.4.1"
gem "sanitize"
gem "ae_users_legacy"
gem "heroku_external_db"
gem "hoptoad_notifier"

group :development do
  gem "bullet"
  gem "thin"
end

group :test do
  gem 'database_cleaner'
  gem 'shoulda'
  gem 'factory_girl', "~> 1.2.3"
  gem 'launchy'
  gem 'capybara'
  gem 'cucumber'
  gem 'cucumber-rails'
  gem 'thin'
#  gem 'culerity'
#  platforms :jruby do
#    gem 'celerity'
#  end
#  gem 'akephalos', :path => '/Users/nbudin/code/akephalos'
end
