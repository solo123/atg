class Payment < ActiveRecord::Base
  belongs_to :payment_data, :polymorphic => true
  belongs_to :pay_from, :polymorphic => true
  belongs_to :pay_to, :polymorphic => true
  belongs_to :pay_method, :polymorphic => true
  belongs_to :operator, :class_name => 'EmployeeInfo'
  belongs_to :account

  validate :check_amount

  def check_amount
    errors.add(:amount, 'Payment amount cannot be 0.') if amount == 0
  end
end
