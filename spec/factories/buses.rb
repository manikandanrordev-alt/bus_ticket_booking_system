FactoryBot.define do
  factory :bus do
    association :operator
    sequence(:name) { |n| "Bus #{n}" }
    bus_type { "ac" }
  end
end