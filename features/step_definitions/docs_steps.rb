Given /^an? (.*) doc named \"([^\"]*)\" in \"([^\"]*)\"$/ do |tmpl_name, name, project_name|
  assert project = Project.find_by_name(project_name)
  assert tmpl = project.doc_templates.find_by_name(tmpl_name)
  assert project.docs.create(:doc_template => tmpl, :name => name)
end

Then /^I should see the following fields:$/ do |expected_fields_table|
  display_table = tableish('table.doc_attrs tr', 'td.name, td.value')
  actual_table = table([['name', 'value']] + display_table)
  expected_fields_table.diff!(actual_table)
end

When /^I add a new "([^\"]*)" relationship to "([^\"]*)"$/ do |relationship_type_name, target|
  within ".vellumRelationshipBuilder" do
    assert_equal 0, page.evaluate_script("jQuery('select\#relationship_target_id:visible').size()")
    assert_equal 1, page.evaluate_script("jQuery('.vellumRelationshipBuilder button:disabled').size()")
    
    select(relationship_type_name, :from => "relationship[relationship_type_id_and_source_direction]")
    sleep 2
    assert_equal 1, page.evaluate_script("jQuery('.vellumRelationshipBuilder select[name=\"relationship[target_id]\"]:visible').size()")
  
    When %{I select "#{target}" from "relationship[target_id]"}
    assert_equal 1, page.evaluate_script("jQuery('.vellumRelationshipBuilder button:enabled').size()")
  
    click_on('Add')
  end
  Then %{I should see "#{relationship_type_name} #{target}" within "\#relationships ul"}
end