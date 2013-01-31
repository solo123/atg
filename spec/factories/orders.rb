FactoryGirl.define do
  
  factory :schedule_price do
    price_adult 100
    price_child 80
    price1 100
    price2 180
    price3 260
    price4 340
  end
  factory :schedule do
    tour
    association :price, factory: :schedule_price, strategy: :create
    departure_date '2013-2-1'
    return_date '2013-2-3'
    status 1
  end
  factory :schedule_assignment do
    schedule
  end

  factory :order_price do
    actual_amount 2000
    balance_amount 1000
  end
  factory :user_info do
    full_name "customer 01"
    status 1
  end
  factory :order_detail do
    user_info
  end
  factory :order do
    order_number 'ABC00001'
    schedule
    order_price
    order_detail
    status 1
  end

end

