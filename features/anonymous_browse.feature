Feature: Browse Vellum anonymously
  In order to browse Vellum with no privileges
  As an anonymous user
  I want to surf the site without seeing any controls or hidden content

  Scenario: Projects page
    Given I am on the projects page
    Then I should see "Projects"
    And I should see "Log in"
    And I should not see "Create"