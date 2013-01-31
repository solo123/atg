require 'spec_helper'

describe "Order" do
  it "order data init" do
    order = FactoryGirl.build(:order)
    order.should be_valid
    order.order_price.should_not be_nil
    order.order_detail.should_not be_nil
    order.order_detail.user_info.should_not be_nil
  end
  it "order ready_to_payment" do
    order = FactoryGirl.build(:order)
    order.should be_valid
    order.should be_ready_to_payment
  end
end

