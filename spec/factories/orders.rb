FactoryGirl.define do
  factory :order_user, class: UserInfo do
    full_name "order user 01"
    status 1
  end
  factory :order_detail do
    association :user_info, factory: :order_user
    full_name "order user 01"
  end

  factory :order_price_2000, class: OrderPrice do
    actual_amount 2000
    balance_amount 1000
  end

  factory :valid_new_order, class: Order do
    order_number 'ABC00001'
    association :order_price, factory: :order_price_2000
    order_detail
    status 1
  end

  factory :invalid_order_without_price, class: Order do
    order_number 'ABC000002'
    order_detail
    status 1
  end

end

