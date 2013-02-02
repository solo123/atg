Feature: Visit common pages and sucess
  Background:
    Given Signin as admin

  Scenario: visit destinations pages
    Given browse the destinations page

  Scenario: visit orders pages
    Given browse the orders page
    Then I should have the selector "list_orders"

  Scenario: visit order detail
    Given goto order page



