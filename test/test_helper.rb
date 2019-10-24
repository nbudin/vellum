require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

ENV["RAILS_ENV"] = "test"
require File.expand_path("../../config/environment", __FILE__)
require 'rails/test_help'

require 'minitest/reporters'
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

require 'capybara/rails'
require 'selenium/webdriver'

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.register_driver :headless_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: { args: %w(headless disable-gpu) }
  )

  Capybara::Selenium::Driver.new app,
    browser: :chrome,
    desired_capabilities: capabilities
end

Capybara.javascript_driver = :headless_chrome

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
  end

  teardown do
    Warden.test_reset!
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end

  def database_cleaner_strategy
    :truncation
  end
end
