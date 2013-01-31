require 'spec_helper'

describe "CancleOrder" do
  it "cancle order to voucher" do
    company = FactoryGirl.create(:company, short_name: "company1", company_name: "company_1", status: 1)
    order = FactoryGirl.create(:order, status: 2)
    operator = FactoryGirl.create(:employee_info, nickname: 'operator')
    voucher = FactoryGirl.build(:voucher)
    operator.company = company
    order.order_price.actual_amount = 2000
    order.order_price.balance_amount = 1000
    order.order_price.save

    biz_payment = Biz::OrderPayment.new
    biz_payment.cancle_to_voucher(voucher, operator)
    voucher.should be_new_record
    biz_payment.errors.should_not be_blank, "cancled without voucher data."
    voucher.payment.should be_nil

    voucher.order = order
    voucher.order_amount = order.order_price.actual_amount - order.order_price.balance_amount
    voucher.amount = 100
    voucher.refund_fee = 100
    voucher.expire_date = Date.current.next_year
    order.order_price.actual_amount.should == 2000
    order.order_price.balance_amount.should == 1000
    biz_payment.cancle_to_voucher(voucher, operator)
    biz_payment.errors.should_not be_blank, "voucher amount not match"

    voucher.amount = voucher.order_amount - voucher.refund_fee
    biz_payment.cancle_to_voucher(voucher, operator)
    biz_payment.errors.should be_blank, biz_payment.errors.inspect
    order.should_not be_changed, "order status not save"
    order.status.should == 7
    order.order_price.balance_amount.should == order.order_price.actual_amount
    payment = voucher.payment
    payment.should_not be_nil
    (voucher.amount + voucher.refund_fee).should == 0 - payment.amount
  end
end

