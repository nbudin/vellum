require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

ENV["RAILS_ENV"] = "test"
require File.expand_path("../../config/environment", __FILE__)
require 'rails/test_help'

require 'capybara/rails'
require 'capybara/poltergeist'

class ActiveSupport::TestCase
  self.use_transactional_fixtures = false
  self.use_instantiated_fixtures  = false

  setup do
    DatabaseCleaner.strategy = database_cleaner_strategy
    DatabaseCleaner.start
  end
  
  teardown do
    DatabaseCleaner.clean
  end
  
  def database_cleaner_strategy
    :transaction
  end
end

class ActionController::TestCase
  include Devise::TestHelpers
  
  def create_logged_in_person
    @person = FactoryGirl.create(:person)
    sign_in(@person)
  end
end

class ActionDispatch::IntegrationTest
  include Capybara::DSL
  include Warden::Test::Helpers
    
  setup do
    Warden.test_mode!
    Capybara.current_driver = :rack_test
  end
  
  teardown do
    Warden.test_reset!
  end
  
  def database_cleaner_strategy
    :truncation
  end
end