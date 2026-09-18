class Trip < ApplicationRecord
  belongs_to :operator
  belongs_to :bus

  has_many :trip_seats, dependent: :destroy
  has_many :seats, through: :trip_seats
  has_many :bookings, dependent: :restrict_with_error

  validates :from_city, :to_city, presence: true
  validates :departure_at, :arrival_at, :price, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }

  validate :arrival_after_departure
  validate :bus_belongs_to_operator

  private

  def arrival_after_departure
    return if departure_at.blank? || arrival_at.blank?

    errors.add(:arrival_at, "must be after departure") if arrival_at <= departure_at
  end

  def bus_belongs_to_operator
    return if bus.blank? || operator.blank?

    if bus.operator_id != operator_id
      errors.add(:bus, "must belong to the selected operator")
    end
  end
end