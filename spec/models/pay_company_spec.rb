require 'spec_helper'

describe "Pay Company" do
  it "pay by company" do
    order = FactoryGirl.create(:order)
    operator = FactoryGirl.create(:employee_info, nickname: 'operator')
    company = FactoryGirl.create(:company, short_name: 'test company', status: 1)
    pay = FactoryGirl.build(:pay_company, amount: 301, company_discount: 100, additional_discount: 100)

    biz_payment = Biz::OrderPayment.new
    biz_payment.pay(order, pay, operator)
    biz_payment.errors.should_not be_blank, "pay company without company"
    pay.should be_new_record

    pay.company = company
    pay.amount.should == 301
    biz_payment.pay(order, pay, operator)
    biz_payment.errors.should be_blank, biz_payment.errors.inspect
    pay.should_not be_changed

    payment = pay.payment
    payment.should_not be_nil
    payment.should_not be_new_record
    payment.amount.should == pay.amount
    payment.operator_id.should == operator.id
    payment.account.should_not be_nil

    pay.reload
    pay.account_receivable.should == pay.amount - pay.company_discount - pay.additional_discount
    pay.status.should == 1
  end
  it "cancle pay by company" do
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





