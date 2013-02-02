Feature: Order Basic Operations

  Scenario: Order Pay
    Given a valid order
    Given a payment amount 101
    When do order payment
    Then order balance decreased 101
    Then order's account found a new history entry in amount 101
 
  Scenario: Pay Credit Card
  Scenario: Pay Check
    Given init biz order_payment, operator, receiver
    Given set pay as pay check
    Given a valid order
    When do the payment
    Then no errors from payment
    Then a payment been created
    Then order balance decreased
    Then receiver account increased
  Scenario: Pay Company Receivable
  Scenario: Pay Voucher


