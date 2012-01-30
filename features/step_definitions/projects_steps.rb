Given /^a project named "(.*)" owned by (.*) (.*)$/ do |name, firstname, lastname|
  person = Person.find_by_firstname_and_lastname(firstname, lastname)
  project = Factory.create(:project, :name => name)
  project.project_memberships.create(:person => person, :admin => true, :author => true)
end

Given /^a project named "(.*)"$/ do |name|
  step "I am on the projects page"
  step %{I follow "Create project..."}
  step %{I fill in "Project Name" with "#{name}"}
  step %{I press "Create"}
  step %{I should see "#{name}"}
end

Given /^the following projects owned by (.*) (.*):$/ do |firstname, lastname, projects|
  projects.hashes.each do |project_hash|
    step %{a project named "#{project_hash[:name]}" owned by #{firstname} #{lastname}}
  end
end

Given /^the following projects:$/ do |projects|
  projects.hashes.each do |project_hash|
    step %{a project named "#{project_hash[:name]}"}
  end
end

Given /^the Louisiana Purchase project owned by (.*) (.*)$/ do |firstname, lastname|
  person = Person.find_by_firstname_and_lastname(firstname, lastname)
  project = Factory.create(:louisiana_purchase)
  project.project_memberships.create(:person => person, :admin => true, :author => true)
end

When /^I delete the (\d+)(?:st|nd|rd|th) project$/ do |pos|
  within(:xpath, "//ul[@class='itemlist']/li[position() = #{pos.to_i}]") do
    click_on "Delete"
  end
end

Then /^I should see the following projects:$/ do |expected_projects_table|
  rows = find('ul.itemlist').all('li')
  display_table = rows.map { |r| r.all('a:not(.button)').map { |c| c.text.strip } }
  actual_table = table([['name']] + display_table.slice(0..-2))
  expected_projects_table.diff!(actual_table)
end
