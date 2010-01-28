Feature: Manage templates
  In order to work with templates
  As a user
  I want to view, create and manage templates in a project

  Scenario: Create a new template
    Given I am logged in as Joe User
    And a project named "Test Project"

    When I am on the project page for Test Project
    And I fill in "structure_template[name]" with "Character"
    And I press "Create template..."
    Then I should see "Character"

    When I follow "Edit template" within "Character"
    Then I should be on the template page for Character

  Scenario: Add fields to a template
    Given I am logged in as Joe User
    And a template named "Character"

    When I am on the template page for Character
    And I follow "Add TextField"
    And I fill in "attr[name]" with "HP"
    And I press "Create"
    Then I should see "HP"

  Scenario: Add relationship types to a template
    Given I am logged in as Joe User
    And a project with the following templates:
      |name|
      |Character|
      |Organization|

    When I am on the template page for Organization
    And I fill in "relationship_type[left_description]" with "includes"
    And I select "Character" from "relationship_type[right_template_id]"
    And I press "Create relationship type..."
    And I go to the template page for Organization
    Then I should see "includes Character"
