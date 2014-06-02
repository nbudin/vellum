require 'test_helper'

class DocTemplatesIntegrationTest < ActionController::IntegrationTest
  setup do
    @person = FactoryGirl.create(:person)
    login_as @person, scope: :person
    
    @project = FactoryGirl.create(:project, name: "Test Project")
    @project.project_memberships.create(person: @person, author: true)
  end
  
  test 'create a new template' do
    visit project_url(@project)
    click_link "Add new template..."
    
    fill_in "Template name", with: "Character"
    fill_in "Add", with: "Mana"
    click_button "Create template"
    
    assert has_content?("Character")
    within("tr:has(td:contains(Mana))") { assert has_content?("Simple text input") }
  end
  
  test 'add fields to a template' do
    @tmpl = FactoryGirl.create(:doc_template, project: @project, name: "Character")
    
    visit doc_templates_url(@project)
    click_link "Character"
    click_link "Edit"
    
    fill_in "Add", with: "HP"
    click_button "Save changes"
    within("tr:has(td:contains(HP))") { assert has_content?("Simple text input") }
  end
  
  test 'remove fields from a template' do
    @tmpl = FactoryGirl.create(:doc_template, project: @project)
    @tmpl.doc_template_attrs.create(name: "HP", ui_type: "text")
    @tmpl.doc_template_attrs.create(name: "Mana", ui_type: "text")

    visit doc_template_url(@project, @tmpl)
    click_link "Edit"
    within("tr:has(td input[value=HP])") { check "Remove" }
    click_button "Save changes"
    
    assert_equal doc_template_url(@project, @tmpl), current_url
    assert has_no_text?("HP")
  end
  
  test 'add relationship types to a template' do
    character = FactoryGirl.create(:doc_template, project: @project, name: "Character")
    organization = FactoryGirl.create(:doc_template, project: @project, name: "Organization")
    
    visit doc_template_url(@project, organization)
    click_link "Create relationship type..."
    
    fill_in "Relationship Type", with: "Organization membership"
    select "Character", from: "Second template"
    click_button "Continue"
    
    assert has_content?("Phrasing")
    fill_in "An Organization", with: "includes"
    fill_in "And a Character", with: "is a member of"
    click_button "Create relationship type"
    
    visit doc_template_url(@project, organization)
    assert has_content?("includes Character")
  end

  test 'remove relationship types from a template' do
    character = FactoryGirl.create(:doc_template, project: @project, name: "Character")
    organization = FactoryGirl.create(:doc_template, project: @project, name: "Organization")
    rel_type = FactoryGirl.create(:relationship_type, project: @project,
      left_template: organization, right_template: character, left_description: "includes")
      
    visit doc_template_url(@project, organization)
    within("li.list-group-item:contains('includes')") { click_button "Delete" }
    
    assert_equal doc_template_url(@project, organization), current_url
    assert has_no_content?("includes Character")
  end
  
  test 'delete a template' do
    character = FactoryGirl.create(:doc_template, project: @project, name: "Character")
    
    visit doc_templates_url(@project)
    within("li.list-group-item:contains('Character')") { click_button "Delete" }
    
    assert_equal doc_templates_url(@project), current_url
    assert has_no_content?("Character")
  end
end