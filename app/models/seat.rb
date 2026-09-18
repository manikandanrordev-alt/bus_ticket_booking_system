class Seat < ApplicationRecord
  belongs_to :bus

  has_many :trip_seats, dependent: :restrict_with_error

  enum :seat_type, {
    seater: "seater",
    sleeper: "sleeper"
  }

  validates :seat_number, presence: true
  validates :seat_type, presence: true
  validates :seat_number, uniqueness: { scope: :bus_id }
end