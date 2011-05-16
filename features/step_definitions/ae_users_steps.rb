def email_address_from_name(firstname, lastname)
  "#{firstname.downcase}.#{lastname.downcase}@example.com"
end

def password_from_name(firstname, lastname)
  "MyNameIs#{firstname}#{lastname}"
end

def logged_in?
  find('.authbox a:last').text =~ /Log\s+out/i
end

Then /^I should be logged in$/ do
  assert logged_in?
end

Then /^I should be logged in as (.*) (.*)$/ do |firstname, lastname|
  assert_match /#{firstname}\s+#{lastname}/, find('.authbox a:first').text
end

Given /^the user (.*) (.*) exists$/ do |firstname, lastname|
  email = email_address_from_name(firstname, lastname)
  person = Person.find_or_create_by_username(email)
  assert person.update_attributes(:firstname => firstname, :lastname => lastname, :email => email)
end

Given /^I log in as (.*) (.*)$/ do |firstname, lastname|
  Given "I am on the home page"
  unless logged_in?
    Given "I follow \"Log in\""
    And "I fill in \"Username\" with \"#{email_address_from_name(firstname, lastname)}\""
    And "I fill in \"Password\" with \"#{password_from_name(firstname, lastname)}\""
    And "I press \"Login\""
    Then "I should be logged in as #{firstname} #{lastname}"
  end
end

Given /^I am logged in as (.*) (.*)$/ do |firstname, lastname|
  Given "the user #{firstname} #{lastname} exists"
  And "I log in as #{firstname} #{lastname}"
end