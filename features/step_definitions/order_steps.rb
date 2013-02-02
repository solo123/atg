Given /^a payment amount (\d+)$/ do |amount|
  @payment = FactoryGirl.create(:normal_payment, amount: amount)
end
When /^do order payment$/ do
  @pre_order_balance = @order.order_price.balance_amount
  @order.pay(@payment)
end
Then /^order balance decreased (\d+)$/ do |amount|
  @order.order_price.balance_amount.should == @pre_order_balance - amount.to_f
end
Then /^order's account found a new history entry in amount (\d+)$/ do |amount|
  hist = @order.account_histories.where(:payment_id => @payment.id)
  hist.should_not be_blank
  hist.length.should == 1
  a_hist = hist.first
  a_hist.balance_before.should == @pre_order_balance
  a_hist.amount.should == amount.to_f
  a_hist.balance_after.should == @order.order_price.balance_amount
end

