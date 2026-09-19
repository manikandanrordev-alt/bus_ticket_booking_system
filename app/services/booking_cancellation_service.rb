# frozen_string_literal: true

class BookingCancellationService
  CANCELLATION_FEE = 50.00

  def initialize(booking:)
    @booking = booking
  end

  def call
    result = ActiveRecord::Base.transaction do
      booking = Booking.lock.find(@booking.id)

      validate_booking!(booking)
      validate_cancellation_window!(booking)

      refund_amount = calculate_refund(booking)

      release_seats!(booking)

      booking.update!(status: "cancelled")

      {
        booking: booking,
        refund_amount: refund_amount
      }
    end

    # Send notification only after the cancellation transaction commits.
    SendBookingNotificationJob.perform_later(
      result[:booking].id,
      "cancellation"
    )

    result
  end

  private

  attr_reader :booking

  def validate_booking!(booking)
    unless booking.confirmed?
      raise ArgumentError, "Only confirmed bookings can be cancelled"
    end
  end

  def validate_cancellation_window!(booking)
    departure_at = booking.trip.departure_at

    if departure_at <= 1.hour.from_now
      raise ArgumentError, "Booking can only be cancelled at least 1 hour before departure"
    end
  end

  def calculate_refund(booking)
    [booking.total_amount - CANCELLATION_FEE, 0].max
  end

  def release_seats!(booking)
    trip_seat_ids = booking.booking_seats.pluck(:trip_seat_id)

    TripSeat
      .where(id: trip_seat_ids)
      .update_all(status: "available")
  end
end