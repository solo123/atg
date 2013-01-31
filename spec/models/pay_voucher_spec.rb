require 'spec_helper'

describe "Pay Voucher" do
  it "pay by voucher" do
    order = FactoryGirl.create(:order)
    operator = FactoryGirl.create(:employee_info, nickname: 'operator')
    voucher = FactoryGirl.create(:voucher, amount: 123, status: 1)
    pay = FactoryGirl.build(:pay_voucher, voucher: voucher, amount: 113, fee: 10)
    company = FactoryGirl.create(:company, short_name: 'company1')
    operator.company = company

    biz_payment = Biz::OrderPayment.new
    biz_payment.pay(order, pay, operator)
    biz_payment.errors.should be_blank, biz_payment.errors.inspect

    pay.reload
    payment = pay.payment
    payment.should_not be_nil
    payment.should_not be_new_record
    pay.amount.should == 123 - 10
    payment.amount.should == pay.amount
    payment.operator_id.should == operator.id
    payment.account.should_not be_nil
    pay.voucher.status.should == 0
    
    p = biz_payment.withdraw(pay, operator)
    biz_payment.errors.should be_blank, biz_payment.errors.inspect
    withdraw_pay = p.pay_method
    withdraw_pay.voucher.id.should == voucher.id
    withdraw_pay.voucher.status.should == 1
    withdraw_pay.amount.should == 0 - pay.amount
    p.amount.should == withdraw_pay.amount
    withdraw_pay.status.should == 0
    p.pay_method.status.should == 0
  end
end





