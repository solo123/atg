class PayVoucher < ActiveRecord::Base
  belongs_to :payment
  belongs_to :account
  belongs_to :voucher
end

