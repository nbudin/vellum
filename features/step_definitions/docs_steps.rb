Given /^an? (.*) doc named "([^\"]*)" in \"([^\"]*)\"$/ do |tmpl_name, name, project_name|
  assert project = Project.find_by_name(project_name)
  assert tmpl = project.doc_templates.find_by_name(tmpl_name)
  assert project.docs.create(:doc_template => tmpl, :name => name)
end

Then /^I should see the following fields:$/ do |expected_fields_table|
  display_table = tableish('dl.doc_attrs dt', lambda{|dt| [dt, dt.next]})
  actual_table = table([['name', 'value']] + display_table)
  expected_fields_table.diff!(actual_table)
end