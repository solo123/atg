require 'spec_helper'

describe "Pay Check" do
  it "pay by check" do
    order = FactoryGirl.create(:order)
    receiver = FactoryGirl.create(:employee_info, nickname: 'receiver')
    operator = FactoryGirl.create(:employee_info, nickname: 'operator')
    pay = FactoryGirl.build(:pay_check, amount: 101, check_number: '111-222-333')

    biz_payment = Biz::OrderPayment.new
    biz_payment.pay(order, pay, operator)
    biz_payment.errors.should_not be_blank, "pay without account"
    pay.should be_new_record

    pay.received_by = receiver
    pay.amount.should == 101
    biz_payment.pay(order, pay, operator)
    biz_payment.errors.should be_blank, biz_payment.errors.inspect

    payment = pay.payment
    payment.should_not be_nil
    payment.should_not be_new_record
    payment.amount.should == pay.amount
    payment.operator_id.should == operator.id
    payment.account.should_not be_nil
  end
  it "cancle pay by check" do
    order = FactoryGirl.create(:order)
    receiver = FactoryGirl.create(:employee_info, nickname: 'receiver')
    operator = FactoryGirl.create(:employee_info, nickname: 'operator')
    pay = FactoryGirl.build(:pay_check, amount: 101, check_number: '111-222-333')

    biz_payment = Biz::OrderPayment.new
    pay.received_by = receiver
    biz_payment.pay(order, pay, operator)
    biz_payment.errors.should be_blank, biz_payment.errors.inspect

    payment = pay.payment

    pay.should_not be_new_record, "pay credit card not saved"
    pay.status.should == 1

    p = biz_payment.withdraw(pay, operator)
    biz_payment.errors.should be_blank, biz_payment.errors.inspect
    withdraw_pay = p.pay_method
    withdraw_pay.check_number.should == pay.check_number
    withdraw_pay.amount.should == 0 - pay.amount
    p.amount.should == withdraw_pay.amount
    withdraw_pay.status.should == 0
    p.pay_method.status.should == 0
  end
end




