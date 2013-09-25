require 'test_helper'

class MapsIntegrationTest < ActionController::IntegrationTest
  setup do  
    @person = FactoryGirl.create(:person)
    @project = FactoryGirl.create(:louisiana_purchase)
    @project.project_memberships.create(person: @person, author: true)
    login_as @person, scope: :person
  end

  test 'create a new map' do
    visit maps_path(@project)
    
    fill_in "Name", with: "Plot web"
    click_button "Create map"
    
    assert_equal map_path(@project, Map.find_by_name("Plot web")), current_path
    assert has_content?("Plot web")
  end
  
  test 'add templates and relationship types to a map' do
    map = FactoryGirl.create(:map, project: @project, name: "Organization Membership")
    
    visit map_path(@project, map)
    select "Characters", from: "mapped_doc_template[doc_template_id]"
    within("#docs") { click_button "Add" }
    assert_equal map_path(@project, map), current_path
    within("#docs ul.itemlist") { assert has_content?("Characters") }
    
    select "Organizations", from: "mapped_doc_template[doc_template_id]"
    within("#docs") { click_button "Add" }
    within("#docs ul.itemlist") { assert has_content?("Organizations") }
    
    select "Organization includes Character", from: "mapped_relationship_type[relationship_type_id]"
    within("#relationships") { click_button "Add" }
    within("#relationships ul.itemlist") { assert has_content?("Organization includes Character") }
  end
  
  test 'delete a map' do
    map = FactoryGirl.create(:map, project: @project, name: "Organization Membership")
    
    visit map_path(@project, map)
    click_button "Delete"
    
    assert_equal maps_path(@project), current_path
    assert has_no_content?("Organization Membership")
  end
end