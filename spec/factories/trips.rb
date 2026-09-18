# frozen_string_literal: true

FactoryBot.define do
  factory :trip do
    association :operator

    from_city { "Coimbatore" }
    to_city { "Chennai" }
    departure_at { 2.hours.from_now }
    arrival_at { 7.hours.from_now }
    price { 750.00 }

    after(:build) do |trip|
      trip.bus ||= build(
        :bus,
        operator: trip.operator
      )
    end
  end
end