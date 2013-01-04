class PayCash < ActiveRecord::Base
  belongs_to :payment
  belongs_to :account

  validates :amount, :numericality => {:greater_than => 0 }
end
