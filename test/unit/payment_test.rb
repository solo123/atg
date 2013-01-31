require 'test_helper'

class PaymentTest < ActiveSupport::TestCase
  test "Pay cash" do
    pay_cash = PayCash.new
    pay_cash.amount = 101

    assert !pay_cash.save
  end
end
