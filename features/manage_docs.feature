Feature: Manage docs
  Scenario: Create a new doc
    Given I am logged in as Joe User
    And a project named "Test Project"
    And a template named "Character" in "Test Project" with the following fields:
      |name        |type                   |choices           |
      |HP          |Simple text input      |                  |
      |Gender      |Radio buttons          |male, female      |
      |Importance  |Drop-down list         |high, medium, low |
      |Affiliations|Multiple selection list|North, South, East|
      |GM Notes    |Rich text input        |                  |

    When I am on the project page for Test Project
    Then I should see "Characters"

    When I follow "Add new Character"
    Then show me the page
    And I fill in "Name" with "Grognar"
    And I fill in "HP" with "50"
    And I choose "male"
    And I select "low" from "Importance"
    And I check "North"
    And I check "East"
    And I fill in "GM Notes" with "Grognar is a moron."
    And I press "Create"
    Then I should see "Grognar"

  Scenario: Link two docs
    Given I am logged in as Joe User
    And a project named "Test Project"
    And a template named "Character" in "Test Project"
    And a template named "Organization" in "Test Project"
    And a relationship type where "Organization" includes "Character" in "Test Project"
    And a Character doc named "King Louis" in "Test Project"
    And an Organization doc named "France" in "Test Project"

    When I am on the project page for Test Project
    Then I should see "King Louis" within "h2:contains('Characters') + div"
    And I should see "France" within "h2:contains('Organizations') + div"

    When I follow "Details" within "li:contains('France')"
    And I add a new "includes" relationship to "King Louis"
    Then I should see "includes King Louis"

  Scenario: Reassign a doc
    Given I am logged in as Joe User
    And a project named "Test Project"
    And a template named "Character" in "Test Project"
    And a Character doc named "Governor Sanford" in "Test Project"

    When I am on the doc page for Governor Sanford
    Then the "Assigned to" field should have "nobody" selected

    When I select "Joe User" from "Assigned to"
    And I press "Reassign"
    Then I should be on the doc page for Governor Sanford
    And the "Assigned to" field should have "Joe User" selected

    When I am on the project page for Test Project
    Then I should see "Assigned to Joe User"