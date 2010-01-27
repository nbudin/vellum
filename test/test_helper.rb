ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'
require 'webrat'

Webrat.configure do |config|
  config.mode = :rails
end

class ActiveSupport::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Add more helper methods to be used by all tests here...
  def build_schema_for_attr_value(field_type, value_type)
    @field = Factory.build(field_type)
    @attr = Factory.build(:attr)
    @attr.attr_configuration = @field
    @t = @attr.structure_template
    @project = @t.project
    @structure = Factory.build(:structure, :project => @project, :structure_template => @t)
    @avm = Factory.build(:attr_value_metadata, :structure => @structure, :attr => @attr)
    @value = Factory.build(value_type, :attr_value_metadata => @avm)
  end

  def create_logged_in_person
    @person = Person.create

    assert @person.email_addresses.create(:address => "test#{@person.id}@example.com", :primary => true)
    @person.email_addresses.reload
    assert @person.primary_email_address
    assert_equal @person.primary_email_address, "test#{@person.id}@example.com"
    
    @request.session[:person] = @person.id
  end

  def parse_json_response
    begin
        JSON.parse(@response.body)
    rescue
    end
  end
end

module Shoulda
  class Context
    def should_respond_with_json
      should "respond with valid JSON" do
        assert parse_json_response
      end
    end
  end
end