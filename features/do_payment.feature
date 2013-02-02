Feature: Pay Orders
  In order to pay a order
  As an operator
  I want to pay for a order

  Scenario: Pay Cash
    Given init biz order_payment, operator, receiver
    Given set pay as pay cash
    Given a invalid order
    When do the payment
    Then get errors from payment
    Given a valid order
    When do the payment
    Then no errors from payment
    Then a payment been created
    Then order balance decreased
    Then receiver account increased
 
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

