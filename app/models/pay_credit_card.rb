class PayCreditCard < ActiveRecord::Base
  belongs_to :payment
  belongs_to :account
  belongs_to :user_info
end

