# frozen_string_literal: true

FactoryBot.define do
  factory :booking_seat do
    association :booking
    association :trip_seat
    price { 750.00 }
  end
end