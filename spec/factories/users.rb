FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:phone_number) { |n| "+9198765432#{n.to_s.rjust(2, '0')}" }
  end
end