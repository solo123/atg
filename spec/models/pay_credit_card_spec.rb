require 'spec_helper'

describe "Pay Credit Card" do
  it "pay by credit card" do
    order = FactoryGirl.create(:order)
    operator = FactoryGirl.create(:employee_info, nickname: 'operator')
    pay = FactoryGirl.build(:pay_credit_card, amount: 101, card_number: '339933993399')
    company = FactoryGirl.create(:company, short_name: 'company1')
    operator.company = company

    biz_payment = Biz::OrderPayment.new
    pay.amount.should == 101
    biz_payment.pay(order, pay, operator)
    biz_payment.errors.should be_blank, biz_payment.errors.inspect

    payment = pay.payment
    payment.should_not be_nil
    payment.should_not be_new_record
    payment.amount.should == pay.amount

    payment.operator_id.should == operator.id
    payment.account.should_not be_nil
    pay.reload
    pay.account.should_not be_nil
  end
  it "cancle pay by credit card" do
    order = FactoryGirl.create(:order)
    operator = FactoryGirl.create(:employee_info, nickname: 'operator')
    pay = FactoryGirl.build(:pay_credit_card, amount: 101)
    company = FactoryGirl.create(:company, short_name: 'company1')
    operator.company = company

    biz_payment = Biz::OrderPayment.new
    biz_payment.pay(order, pay, operator)
    biz_payment.errors.should be_blank, biz_payment.errors.inspect

    payment = pay.payment
    acc_balance = payment.balance_data('Account')

    pay.should_not be_new_record, "pay credit card not saved"
    pay.status.should == 1

    p = biz_payment.withdraw(pay, operator)
    biz_payment.errors.should be_blank, biz_payment.errors.inspect
    withdraw_pay = p.pay_method
    withdraw_pay.card_number.should == pay.card_number
    withdraw_pay.amount.should == 0 - pay.amount
    p.amount.should == withdraw_pay.amount
    withdraw_pay.status.should == 0
    p.pay_method.status.should == 0
  end
end



