FactoryBot.define do
  factory :bus_amenity do
    association :bus
    association :amenity
  end
end