Feature: Manage structures

  Scenario: Create a new structure
    Given I am logged in as Joe User
    And a project named "Test Project"
    And a template named "Character" in Test Project
    And a text field named "HP" on Character

    When I am on the project page for Test Project
    Then I should see "Characters"

    When I follow "Add new Character"
    And I fill in "Name" with "Grognar"
    And I fill in "HP" with "50"
    And I press "Create"
    Then I should see "Grognar"

  Scenario: Link two structures
    Given I am logged in as Joe User
    And a project named "Test Project"
    And a template named "Character" in Test Project
    And a template named "Organization" in Test Project
    And a relationship type where "Character" includes "Organization" in Test Project
    And a Character structure named "King Louis" in Test Project
    And an Organization structure named "France" in Test Project

    When I am on the project page for Test Project
    Then show me the page
    Then I should see "King Louis" within "Characters"
    And I should see "France" within "Organizations"

    When I follow "King Louis"
    Then show me the page

  Scenario: Reassign a structure
    Given I am logged in as Joe User
    And a project named "Test Project"
    And a template named "Character" in Test Project
    And a Character structure named "Governor Sanford" in Test Project

    When I am on the structure page for Governor Sanford
    Then show me the page
    Then the "Assigned to" field should contain "nobody"

    When I select "Joe User" from "Assigned to"
    And I press "Reassign"
    Then the "Assigned to" field should contain "Joe User"

    When I visit the project page for Test Project
    Then I should see "Assigned to Joe User"