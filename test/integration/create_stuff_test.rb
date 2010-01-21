require 'test_helper'

class CreateStuffTest < ActionController::IntegrationTest
  def setup
    @person = Person.create
    @account = @person.create_account :password => "password", :active => true
    @email_address = @person.email_addresses.create :address => "test@test.com", :primary => true

    visit "/"
    click_link "Log in"

    fill_in "Email address", :with => "test@test.com"
    choose "Yes, my password is:"
    fill_in "login[password]", :with => "password"
    click_button "Log in"
  end

  test "make some templates" do
    click_link "Template Schemas"

    fill_in "template_schema[name]", :with => "My new template schema"
    click_button "Create template schema..."

    fill_in "structure_template[name]", :with => "Character"
    click_button "Create template..."

    click_link "Add TextField"
    fill_in "attr[name]", :with => "HP"
    click_button "Create"

    click_link "My new template schema"
    fill_in "structure_template[name]", :with => "Organization"
    click_button "Create template..."

    fill_in "relationship_type[left_description]", :with => "includes"
    select "Character", :from => "relationship_type[right_template_id]"
    click_button "Create relationship type..."
  end
end
