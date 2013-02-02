require 'spec_helper'

describe Payment do
  it "pay by cash" do
    order = FactoryGirl.create(:order)
    operator = FactoryGirl.create(:employee_info, nickname: 'operator')
    receiver = FactoryGirl.create(:employee_info, nickname: 'receiver')
    pay_cash = FactoryGirl.build(:pay_cash, received_by_id: nil, amount: 100)

    biz_payment = Biz::OrderPayment.new
    pay_cash.received_by.should be_nil
    biz_payment.pay(order, pay_cash, operator)
    biz_payment.errors.should_not be_blank, "pay without account"
    pay_cash.payment.should be_nil
    pay_cash.should be_new_record

    pay_cash.received_by = receiver
    pay_cash.amount.should == 100
    biz_payment.pay(order, pay_cash, operator)
    biz_payment.errors.should be_blank, biz_payment.errors.inspect

    payment = pay_cash.payment
    payment.should_not be_nil
    payment.should_not be_new_record
    payment.amount.should == pay_cash.amount
    payment.operator_id.should == operator.id
    payment.account.should_not be_nil
    payment.account.owner_id.should == receiver.id

    hist = payment.balance_data('Order')
    hist.should_not be_nil
    hist.should_not be_new_record
    hist.balance_after.should == hist.balance_before - hist.amount
    hist.amount.should == pay_cash.amount

    hist = payment.balance_data('Account')
    hist.should_not be_nil
    payment.account.should_not be_changed
  end

  it "order status" do
    order = FactoryGirl.create(:order)
    employee_info = FactoryGirl.create(:employee_info)
    receiver = FactoryGirl.create(:employee_info, nickname: 'receiver')
    pay_cash = FactoryGirl.build(:pay_cash, received_by: receiver, amount: 100)
    biz_payment = Biz::OrderPayment.new
    biz_payment.pay(order, pay_cash, employee_info)
    pay_cash.amount.should == 100
    payment = pay_cash.payment
    order.status.should == 2

    pay_cash = FactoryGirl.build(:pay_cash, received_by: receiver, amount: 900)
    biz_payment.pay(order, pay_cash, employee_info)
    payment = pay_cash.payment
    order.status.should == 3
  end

  it "refund by cash" do
    order = FactoryGirl.create(:order, status: 3)
    operator = FactoryGirl.create(:employee_info, nickname: 'operator')
    receiver = FactoryGirl.create(:employee_info, nickname: 'receiver')
    refund = FactoryGirl.build(:pay_cash, received_by_id: nil, amount: -100)

    biz_payment = Biz::OrderPayment.new
    refund.received_by.should be_nil
    biz_payment.refund(order, refund, operator)
    biz_payment.errors.should_not be_blank, "refund without receiver"
    refund.payment.should be_nil
    refund.should be_new_record

    refund.received_by = receiver
    refund.amount.should == -100
    biz_payment.refund(order, refund, operator)
    biz_payment.errors.should be_blank, biz_payment.errors.inspect

    payment = refund.payment
    payment.should_not be_nil
    payment.should_not be_new_record
    payment.amount.should == refund.amount
    
    order_balance = payment.balance_data('Order')
    order_balance.should_not be_nil
    order_balance.amount.should == payment.amount
    order_balance.balance_after.should == order_balance.balance_before - payment.amount
    payment.operator_id.should == operator.id
    payment.account.should_not be_nil
    payment.account.owner_id.should == receiver.id

    account_balance = payment.balance_data('Account')
    payment.account.should_not be_changed
  end


end
