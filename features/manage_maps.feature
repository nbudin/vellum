Feature: Manage maps
  In order to work with maps
  As a user
  I want to view, create and manage maps in a project

  @javascript
  Scenario: Create a new map
    Given I am on the projects page
    And I follow "Log in"
    
    Given I am logged in as Joe User
    And a project named "Test Project"

    When I am on the project page for Test Project
    And I follow "Maps"
    And I fill in "Name" with "Plot web"
    And I press "Create map"
    Then I should see "Plot web"
    And I should be on the map page for Plot web

  Scenario: Add templates and relationship types to a map
    Given I am logged in as Joe User
    And a project named "Test Project"
    And a template named "Character" in "Test Project"
    And a template named "Organization" in "Test Project"
    And a relationship type where "Organization" includes "Character" in "Test Project"
    And a map named "Organization Membership" in "Test Project"

    When I am on the map page for Organization Membership
    And I select "Characters" from "mapped_doc_template[doc_template_id]"
    And I press "Add" within "div#docs"
    Then I should be on the map page for Organization Membership
    And I should see "Characters" within "#docs ul.itemlist"

    When I select "Organizations" from "mapped_doc_template[doc_template_id]"
    And I press "Add" within "div#docs"
    Then I should see "Organizations" within "#docs ul.itemlist"

    When I select "Organization includes Character" from "mapped_relationship_type[relationship_type_id]"
    And I press "Add" within "div#relationships"
    Then I should see "Organization includes Character" within "#relationships ul.itemlist"

  Scenario: Delete a map
    Given I am logged in as Joe User
    And a project named "Test Project"
    And a template named "Character" in "Test Project"
    And a template named "Organization" in "Test Project"
    And a relationship type where "Organization" includes "Character" in "Test Project"
    And a map named "Organization Membership" in "Test Project"

    When I am on the map page for Organization Membership
    And I press "Delete"
    Then I should be on the maps page for Test Project
    And I should not see "Organization Membership"