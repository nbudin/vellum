Given /^a template named "([^\"]*)"$/ do |name|
  assert tmpl = Factory.create(:doc_template, :name => name)
  tmpl.project.project_memberships.create(:person => controller.current_person, :author => true)
end

Given /^a template named "([^\"]*)" in "([^\"]*)"$/ do |name, project_name|
  assert project = Project.find_by_name(project_name)
  assert tmpl = Factory.create(:doc_template, :name => name, :project => project)
end

Given /^a template named "([^\"]*)" in "([^\"]*)" with the following fields:$/ do |name, project_name, fields|
  step "a template named \"#{name}\" in \"#{project_name}\""
  fields.hashes.each do |field|
    step "I am on the template page for #{name}"
    step "I follow \"Edit\""
    step "I fill in \"Add:\" with \"#{field[:name]}\""
    step "I select \"#{field[:type]}\" from \"Display as:\" within \"tr.willAdd\""
    unless field[:choices].blank?
      step "I fill in \"Choices:\" with \"#{field[:choices]}\" within \"tr.willAdd\""
    end
    step "I press \"Save changes\""

    step "I should see \"#{field[:name]}\""
  end
end

Given /^a project with the following templates:$/ do |table|
  step %{a project named "Test Project"}
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
  rows = find('table.doc_template_attrs').all('tr')
  display_table = rows.map { |r| r.all('td.name, td.value').map { |c| c.text.strip } }
  actual_table = table([['name', 'type']] + display_table)
  expected_fields_table.diff!(actual_table)
end