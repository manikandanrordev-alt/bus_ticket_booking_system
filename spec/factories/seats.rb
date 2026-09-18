FactoryBot.define do
  factory :seat do
    association :bus
    sequence(:seat_number) { |n| "A#{n}" }
    seat_type { "seater" }
  end
end