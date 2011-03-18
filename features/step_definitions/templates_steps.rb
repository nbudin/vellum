Given /^a template named "([^\"]*)"$/ do |name|
  assert tmpl = Factory.create(:doc_template, :name => name)
  tmpl.project.grant(controller.logged_in_person)
end

Given /^a template named "([^\"]*)" in "([^\"]*)"$/ do |name, project_name|
  assert project = Project.find_by_name(project_name)
  assert tmpl = Factory.create(:doc_template, :name => name, :project => project)
end

Given /^a template named "([^\"]*)" in "([^\"]*)" with the following fields:$/ do |name, project_name, fields|
  Given "a template named \"#{name}\" in \"#{project_name}\""
  fields.hashes.each do |field|
    Given "I am on the template page for #{name}"
    And "I follow \"Edit\""
    And "I fill in \"Add:\" with \"#{field[:name]}\""
    And "I select \"#{field[:type]}\" from \"Display as:\" within \"dd.willAdd\""
    unless field[:choices].blank?
      And "I fill in \"Choices:\" with \"#{field[:choices]}\" within \"dd.willAdd\""
    end
    And "I press \"Save changes\""

    Then "I should see \"#{field[:name]}\""
  end
end

Given /^a project with the following templates:$/ do |table|
  Given %{a project named "Test Project"}
  assert project = Project.find_by_name("Test Project")

  table.hashes.each do |tmpl_hash|
    project.doc_templates.create(tmpl_hash)
  end
end

Given /^a relationship type where "([^\"]*)" (.*) "([^\"]*)" in "([^\"]*)"$/ do |left_template_name,
    left_description, right_template_name, project_name|

  assert project = Project.find_by_name(project_name)
  assert left_tmpl = project.doc_templates.find_by_name(left_template_name)
  assert right_tmpl = project.doc_templates.find_by_name(right_template_name)
  assert rt = project.relationship_types.create(:left_template => left_tmpl,
    :right_template => right_tmpl, :left_description => left_description)
end

Then /^I should see the following template fields:$/ do |expected_fields_table|
  display_table = tableish('dl.doc_template_attrs dt', lambda{|dt| [dt, dt.next.next]})
  actual_table = table([['name', 'type']] + display_table)
  expected_fields_table.diff!(actual_table)
end