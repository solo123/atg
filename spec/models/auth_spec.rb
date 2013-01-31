require 'spec_helper'

describe Auth do
  it "basic auth" do
    action = 'test_auth'
    FactoryGirl.create(:auth, role: 'X3', action: action) 
    biz_auth = Biz::AuthOp.new
    biz_auth.check_auth(action, "124").should be_false
    biz_auth.check_auth(action, "1239").should be_true
    biz_auth.check_auth(action, '3X').should be_true
    biz_auth.check_auth(action, '1X').should be_true
  end

end

