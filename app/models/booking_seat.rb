# frozen_string_literal: true

class BookingSeat < ApplicationRecord
  belongs_to :booking
  belongs_to :trip_seat

  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :trip_seat_id, uniqueness: { scope: :booking_id }
end