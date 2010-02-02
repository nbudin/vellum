Given /^a project named "(.*)" owned by (.*) (.*)$/ do |name, firstname, lastname|
  person = Person.find_by_firstname_and_lastname(firstname, lastname)
  project = Factory.create(:project, :name => name)
  project.grant(person)
end

Given /^a project named "(.*)"$/ do |name|
  Given %{a project named "#{name}" owned by #{controller.logged_in_person.name}}
end

Given /^the following projects owned by (.*) (.*):$/ do |firstname, lastname, projects|
  projects.hashes.each do |project_hash|
    Given %{a project named "#{project_hash[:name]}" owned by #{firstname} #{lastname}}
  end
end

Given /^the following projects:$/ do |projects|
  projects.hashes.each do |project_hash|
    Given %{a project named "#{project_hash[:name]}" owned by #{controller.logged_in_person.name}}
  end
end

Given /^the Louisiana Purchase project$/ do
  project = Factory.create(:louisiana_purchase)
  project.grant(controller.logged_in_person.name)
end

When /^I delete the (\d+)(?:st|nd|rd|th) project$/ do |pos|
  visit projects_url
  within("ul.itemlist li:nth-child(#{pos.to_i})") do
    click_link "Delete"
  end
end

Then /^I should see the following projects:$/ do |expected_projects_table|
  display_table = tableish('ul.itemlist li', 'a:not(.button)')
  actual_table = table([['name']] + display_table.slice(0..-2))
  expected_projects_table.diff!(actual_table)
end
