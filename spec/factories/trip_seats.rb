FactoryBot.define do
  factory :trip_seat do
    association :trip
    association :seat
    status { "available" }
  end
end