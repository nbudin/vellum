Given /^a map named "(.*)" in (.*)$/ do |name, project_name|
  assert project = Project.find_by_name(project_name)
  assert Factory.create(:map, :name => name, :project => project)
end