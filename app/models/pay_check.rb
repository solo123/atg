class PayCheck < ActiveRecord::Base
  belongs_to :payment
  belongs_to :account
end

