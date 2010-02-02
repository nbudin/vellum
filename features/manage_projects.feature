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

  Scenario: Create a new project using templates from a different project
    Given I am logged in as Joe User
    And the Louisiana Purchase project
    And I am on the projects page
    And I fill in "project[name]" with "A new project"
    And I select "Louisiana Purchase" from "Using templates from"
    And I press "Create"
    Then I should be on the project page for A new project
    And I should see "A new project"
    And I should see "Characters"
    And I should see "Organizations"
    And I should not see "King Louis"
    And I should not see "France"

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
