FactoryBot.define do
  factory :operator do
    sequence(:name) { |n| "Operator #{n}" }
    rating { 4.5 }
  end
end