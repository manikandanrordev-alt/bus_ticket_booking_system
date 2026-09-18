class TripSeat < ApplicationRecord
  belongs_to :trip
  belongs_to :seat

  enum :status, {
    available: "available",
    held: "held",
    booked: "booked"
  }

  has_many :hold_seats, dependent: :restrict_with_error

  validates :status, presence: true
  validates :seat_id, uniqueness: { scope: :trip_id }

  validate :seat_belongs_to_trip_bus

  private

  def seat_belongs_to_trip_bus
    return if trip.blank? || seat.blank?

    if seat.bus_id != trip.bus_id
      errors.add(:seat, "must belong to the trip bus")
    end
  end
end