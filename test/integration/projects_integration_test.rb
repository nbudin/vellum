require 'test_helper'

class ProjectsIntegrationTest < ActionController::IntegrationTest
  setup do  
    @person = FactoryGirl.create(:person)
    login_as @person, scope: :person
  end

  test 'create a new project' do
    visit projects_path
    click_link "Create project..."
    
    fill_in "Project Name", with: "My awesome project"
    click_button "Create"
    
    assert has_content?("My awesome project")
  end

  test 'create a new project using templates from a different project' do
    lp = FactoryGirl.create(:louisiana_purchase)
    lp.project_memberships.create(person: @person)
    
    visit projects_path
    click_link "Create project..."
    
    fill_in "Project Name", with: "A new project"
    select "Louisiana Purchase", from: "Choose a project to copy templates from:"
    click_button "Create"
    
    assert has_content?("A new project")
    assert has_content?("Characters")
    assert has_content?("Organizations")
    assert has_no_content?("King Louis")
    assert has_no_content?("France")
  end

  test 'delete projects' do
    %w(Groucho Harpo Chico Zeppo Gummo).each do |name|
      project = FactoryGirl.create(:project, name: name)
      project.project_memberships.create(person: @person, admin: true)
    end
    
    visit projects_path
    within(:xpath, "//ul[@class='itemlist']/li[position() = 4]") do
      click_on "Delete"
    end
    
    %w(Groucho Harpo Chico Gummo).each { |name| assert has_content?(name) }
    assert has_no_content?("Zeppo")
  end
end  