# frozen_string_literal: true

class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :trip
  belongs_to :hold

  has_many :booking_seats, dependent: :destroy
  has_many :trip_seats, through: :booking_seats

  enum :status, {
    confirmed: "confirmed",
    cancelled: "cancelled",
    rescheduled: "rescheduled"
  }

  validates :total_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :status, presence: true
  validates :idempotency_key, presence: true, uniqueness: true
end