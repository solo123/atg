Feature: Visit common pages and sucess
  Background:
    Given Signin as admin

  Scenario: visit destinations pages
    Given browse resource page destinations
    Then table list_destinations have 3 rows
    Then check destination's operations




