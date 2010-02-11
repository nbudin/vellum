Given /^an? (.*) doc named "([^\"]*)" in (.*)$/ do |tmpl_name, name, project_name|
  assert project = Project.find_by_name(project_name)
  assert tmpl = project.doc_templates.find_by_name(tmpl_name)
  assert project.docs.create(:doc_template => tmpl, :name => name)
end