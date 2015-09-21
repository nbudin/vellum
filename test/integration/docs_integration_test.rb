require 'test_helper'

class DocsIntegrationTest < ActionDispatch::IntegrationTest
  setup do  
    @person = FactoryGirl.create(:person)
    @project = FactoryGirl.create(:project, name: "Test Project")
    @project.project_memberships.create(person: @person, author: true)
    login_as @person, scope: :person
  end
  
  test 'create a new doc' do
    character = FactoryGirl.create(:doc_template, name: "Character", project: @project)
    FactoryGirl.create(:doc_template_attr, doc_template: character, name: "HP", ui_type: "text")
    FactoryGirl.create(:doc_template_attr, doc_template: character, name: "Gender", ui_type: "radio", choices: ["male", "female"])
    FactoryGirl.create(:doc_template_attr, doc_template: character, name: "Importance", ui_type: "dropdown", choices: ["high", "medium", "low"])
    FactoryGirl.create(:doc_template_attr, doc_template: character, name: "Affiliations", ui_type: "multiple", choices: ["North", "South", "East", "North West"])
    FactoryGirl.create(:doc_template_attr, doc_template: character, name: "GM Notes", ui_type: "textarea")
    
    visit project_url(@project)
    assert has_content?("Characters")
    click_link "Add new Character"
    
    fill_in "Document Name", with: "Grognar"
    fill_in "HP", with: "50"
    choose "male"
    select "low", from: "Importance"
    check "North"
    check "East"
    check "North West"
    fill_in "GM Notes", with: "Grognar is a moron."
    
    click_button "Create Character"
    
    grognar = Doc.find_by_name("Grognar")
    assert_equal doc_path(@project, grognar), current_path
    
    {
      "HP" => 50,
      "Gender" => "male",
      "Importance" => "low",
      "Affiliations" => "North, East, North West",
      "GM Notes" => "Grognar is a moron."
    }.each do |field, value|
      within("tr:has(td.name:contains('#{field}')) td.value") { assert has_content?(value) }
    end
  end
  
  test 'link two docs' do
    Capybara.current_driver = :poltergeist

    character = FactoryGirl.create(:doc_template, project: @project, name: "Character")
    organization = FactoryGirl.create(:doc_template, project: @project, name: "Organization")
    rel_type = FactoryGirl.create(:relationship_type, project: @project,
      left_template: organization, right_template: character, left_description: "includes")
      
    louis = FactoryGirl.create(:doc, project: @project, doc_template: character, name: "King Louis")
    france = FactoryGirl.create(:doc, project: @project, doc_template: organization, name: "France")
    
    visit project_path(@project)
    within("section", text: "Characters") { assert has_content?("King Louis") }
    within("section", text: "Organizations") { assert has_content?("France") }
    
    click_link "France"
    within ".vellumRelationshipBuilder" do
      assert_equal 0, evaluate_script("jQuery('select\#relationship_target_id:visible').size()")
      assert_equal 1, evaluate_script("jQuery('.vellumRelationshipBuilder button:disabled').size()")
    
      select("includes", :from => "relationship[relationship_type_id_and_source_direction]")
      sleep 2
      assert_equal 1, evaluate_script("jQuery('.vellumRelationshipBuilder select[name=\"relationship[target_id]\"]:visible').size()")
  
      select "King Louis", from: "relationship[target_id]"
      assert_equal 1, evaluate_script("jQuery('.vellumRelationshipBuilder button:enabled').size()")
  
      click_on('Add')
    end
    assert has_content?("includes King Louis")
  end
  
  test 'reassign a doc' do
    character = FactoryGirl.create(:doc_template, project: @project, name: "Character")
    doc = FactoryGirl.create(:doc, project: @project, doc_template: character, name: "Governor Sanford")
    
    SiteSettings.instance.tap do |settings|
      settings.site_email = "noreply@aegames.org"
      settings.save!
    end
    
    visit doc_path(@project, doc)
    assert find_field("Assigned to").find("option", text: "nobody").selected?
    
    select @person.name, from: "Assigned to"
    click_button "Reassign"
    assert_equal doc_path(@project, doc), current_path
    assert find_field("Assigned to").find("option", text: @person.name).selected?
    
    visit project_path(@project)
    assert has_content?("Assigned to #{@person.name}")
  end
end