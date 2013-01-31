require 'spec_helper'

describe "Account History" do
  it "sub balance" do
    b = AccountHistory.new
    b.sub_balance(100,10)
    b.balance_before.should == 100
    b.amount.should == 10
    b.balance_after.should == 90
  end
  it "add balance" do
    b = AccountHistory.new
    b.add_balance(100,10)
    b.balance_before.should == 100
    b.amount.should == 10
    b.balance_after.should == 110
  end
end

