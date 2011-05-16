Feature: Manage projects
  In order to create a project
  As a user
  I want to view, create and manage projects
  
  Scenario: Create a new project
    Given I am logged in as Joe User
    And I am on the projects page
    And I follow "Create project..."
    And I fill in "Project Name" with "My awesome project"
    And I press "Create"
    Then I should see "My awesome project"

  Scenario: Create a new project using templates from a different project
    Given I am logged in as Joe User
    And the Louisiana Purchase project owned by Joe User
    And I am on the projects page
    And I follow "Create project..."
    And I fill in "Project Name" with "A new project"
    And I select "Louisiana Purchase" from "Choose a project to copy templates from:"
    And I press "Create"
    Then I should not be on the projects page
    And I should see "A new project"
    And I should see "Characters"
    And I should see "Organizations"
    And I should not see "King Louis"
    And I should not see "France"

  Scenario: Delete projects
    When I am logged in as Joe User
    Given the following projects owned by Joe User:
      |name|
      |Groucho|
      |Harpo|
      |Chico|
      |Zeppo|
      |Gummo|
    And I am on the projects page
    And I delete the 4th project
    Then I should see the following projects:
      |name|
      |Groucho|
      |Harpo|
      |Chico|
      |Gummo|
