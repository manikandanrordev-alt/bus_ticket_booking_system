FactoryBot.define do
  factory :trip do
    association :operator
    association :bus

    from_city { "Coimbatore" }
    to_city { "Chennai" }

    departure_at { 2.hours.from_now }
    arrival_at { 7.hours.from_now }

    price { 750.00 }
  end
end