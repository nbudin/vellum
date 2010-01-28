Given /^a template named "(.*)"$/ do |name|
  assert tmpl = Factory.create(:structure_template, :name => name)
  tmpl.project.grant(controller.logged_in_person)
end

Given /^a template named "(.*)" in (.*)$/ do |name, project_name|
  assert project = Project.find_by_name(project_name)
  assert tmpl = Factory.create(:structure_template, :name => name, :project => project)
end

Given /^a project with the following templates:$/ do |table|
  assert project = Factory.create(:project)
  project.grant(controller.logged_in_person)

  table.hashes.each do |tmpl_hash|
    project.structure_templates.create(tmpl_hash)
  end
end

Given /^a relationship type where "([^\"]*)" (.*) "([^\"]*)" in (.*)$/ do |left_template_name,
    left_description, right_template_name, project_name|

  assert project = Project.find_by_name(project_name)
  assert left_tmpl = project.structure_templates.find_by_name(left_template_name)
  assert right_tmpl = project.structure_templates.find_by_name(right_template_name)
  assert rt = project.relationship_types.create(:left_template => left_tmpl,
    :right_template => right_tmpl, :left_description => left_description)
end