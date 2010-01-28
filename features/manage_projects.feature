Feature: Manage projects
  In order to create a project
  As a user
  I want to view, create and manage projects
  
  Scenario: Create a new project
    Given I am logged in as Joe User
    And I am on the projects page
    And I fill in "project[name]" with "My awesome project"
    And I press "Create"
    Then I should see "My awesome project"

  Scenario: Delete projects
    Given the following projects owned by Joe User:
      |name|
      |Groucho|
      |Harpo|
      |Chico|
      |Zeppo|
      |Gummo|
    When I am logged in as Joe User
    And I am on the projects page
    And I delete the 4th project
    Then I should see the following projects:
      |name|
      |Groucho|
      |Harpo|
      |Chico|
      |Gummo|
