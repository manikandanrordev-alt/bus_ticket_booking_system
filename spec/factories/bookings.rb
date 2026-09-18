# frozen_string_literal: true

FactoryBot.define do
  factory :booking do
    association :user
    association :trip
    association :hold
    total_amount { 750.00 }
    status { "confirmed" }
    sequence(:idempotency_key) { |n| "booking-key-#{n}" }
  end
end