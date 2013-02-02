Given /^init biz order_payment, operator, receiver$/ do
  @biz = Biz::OrderPayment.new
  @operator = FactoryGirl.create(:employee_info, nickname: 'operator')
  @receiver = FactoryGirl.create(:employee_info, nickname: 'receiver')
end
Given /^set pay as pay cash$/ do
  @pay = FactoryGirl.build(:pay_cash, amount: 100, received_by: @receiver)
end
Given /^set pay as pay check$/ do
  @pay = FactoryGirl.build(:pay_check, amount: 100, received_by: @receiver)
end
Given /^a invalid order$/ do
  @order = FactoryGirl.create(:invalid_order_without_price)
end
When /^do the payment$/ do
  @biz.pay(@order, @pay, @operator)
end
Then /^get errors from payment$/ do
  @biz.errors.should_not be_blank
end
Given /^a valid order$/ do
  @order = FactoryGirl.create(:valid_new_order)
end
Then /^no errors from payment$/ do
  @biz.errors.should be_blank, @biz.errors.inspect
end
Then /^a payment been created$/ do
  payment = @pay.payment
  payment.should_not be_nil
  payment.amount.should == @pay.amount
end
Then /^order balance decreased$/ do
  @order.order_price.balance_amount.should == 1000 - 100
end
Then /^receiver account increased$/ do
  account = @biz.get_employee_account(@receiver, @pay.class.name)
  account.should_not be_nil
  account.balance.should == @pay.amount
end


