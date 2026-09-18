# frozen_string_literal: true

class BookingCancellationService
  CANCELLATION_FEE = 50.00

  def initialize(booking:)
    @booking = booking
  end

  def call
    ActiveRecord::Base.transaction do
      booking = Booking.lock.find(@booking.id)

      validate_booking!(booking)

      validate_cancellation_window!(booking)

      refund_amount = calculate_refund(booking)

      release_seats!(booking)

      booking.update!(
        status: "cancelled"
      )

      {
        booking: booking,
        refund_amount: refund_amount
      }
    end
  end

  private

  attr_reader :booking

  def validate_booking!(booking)
    return if booking.confirmed?

    raise ArgumentError, "Booking is no longer active"
  end

  def validate_cancellation_window!(booking)
    if booking.trip.departure_at <= 1.hour.from_now
      raise ArgumentError,
        "Booking can only be cancelled at least 1 hour before departure"
    end
  end

  def calculate_refund(booking)
    [booking.total_amount - CANCELLATION_FEE, 0].max
  end

  def release_seats!(booking)
    trip_seat_ids = booking.booking_seats.pluck(:trip_seat_id)

    TripSeat
      .where(id: trip_seat_ids)
      .order(:id)
      .lock
      .update_all(status: "available")
  end
end
