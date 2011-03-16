Feature: Manage templates
  In order to work with templates
  As a user
  I want to view, create and manage templates in a project

  Scenario: Create a new template
    Given I am logged in as Joe User
    And a project named "Test Project"

    When I am on the project page for Test Project
    And I follow "Templates"
    And I follow "Add new template..."
    And I fill in "Template name" with "Character"
    And I fill in "Add:" with "Mana"
    And I press "Create template"
    Then I should see "Character"
    And I should be on the template page for Character
    And I should see the following template fields:
      |name     |type             |
      |Mana     |Simple text input|

  Scenario: Add fields to a template
    Given I am logged in as Joe User
    And a project named "Test Project"
    And a template named "Character" in "Test Project"

    When I am on the templates page for Test Project
    And I follow "Character"
    And I follow "Edit"
    And I fill in "Add:" with "HP"
    And I press "Save changes"
    Then I should see the following template fields:
      |name    |type             |
      |HP      |Simple text input|

  Scenario: Remove fields from a template
    Given I am logged in as Joe User
    And a project named "Test Project"
    And a template named "Character" in "Test Project" with the following fields:
      |name    |type             |
      |HP      |Simple text input|
      |Mana    |Simple text input|

    When I am on the template page for Character
    And I follow "Edit"
    And I check "Remove" within "dt:contains(HP) + dd"
    And I press "Save changes"
    
    Then I should be on the template page for Character
    And I should not see "HP"

  Scenario: Add relationship types to a template
    Given I am logged in as Joe User
    And a project with the following templates:
      |name|
      |Character|
      |Organization|

    When I am on the template page for Organization
    And I follow "Create relationship type..."
    
    And I fill in "Relationship Type" with "Organization membership"
    And I select "Character" from "Second template"
    And I press "Continue"
    Then I should see "Phrasing"
    
    And I fill in "An Organization" with "includes"
    And I fill in "And a Character" with "is a member of"
    And I press "Create relationship type"
    
    And I go to the template page for Organization
    Then I should see "includes Character"

  Scenario: Remove relationship types from a template
    Given I am logged in as Joe User
    And a project named "Test Project"
    And a template named "Character" in "Test Project"
    And a template named "Organization" in "Test Project"
    And a relationship type where "Organization" includes "Character" in "Test Project"

    When I am on the template page for Organization
    And I press "Delete" within "li:has(a:contains('includes'))"
    Then I should be on the template page for Organization
    And I should not see "includes Character"

  Scenario: Delete a template
    Given I am logged in as Joe User
    And a project named "Test Project"
    And a template named "Character" in "Test Project"

    When I am on the templates page for Test Project
    And I press "Delete" within "li:has(a:contains('Character'))"
    Then I should be on the templates page for Test Project
    And I should not see "Character"