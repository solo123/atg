FactoryGirl.define do 
  factory :destination do
    association :description, title: "dest_1", en: "this is dest_1"
    status 1
  end
 
  factory :tour_price do
  end

  factory :tour do
    days 1
    tour_type 1
    status 1

    association :tour_price, price_adult: 100, price_child: 80, price1: 100, price2: 180, price3: 260, price4: 340
  end
end
