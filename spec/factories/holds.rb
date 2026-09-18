# frozen_string_literal: true

FactoryBot.define do
  factory :hold do
    association :user
    expires_at { 5.minutes.from_now }
    status { "active" }
  end
end