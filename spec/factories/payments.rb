FactoryGirl.define do
  factory :pay_cash do
  end
  factory :pay_credit_card do
  end
  factory :pay_check do
  end
  factory :pay_company do
  end
  factory :pay_voucher do
  end
  factory :voucher do
  end
  factory :normal_payment, class: Payment do
  end

  factory :account do
  end
end
