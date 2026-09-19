# frozen_string_literal: true

class BookingRescheduleService
  def initialize(booking:, new_trip:)
    @booking = booking
    @new_trip = new_trip
  end

  def call
    booking = ActiveRecord::Base.transaction do
      booking = Booking.lock.find(@booking.id)
      new_trip = Trip.lock.find(@new_trip.id)

      validate_booking!(booking)
      validate_trip!(booking, new_trip)

      old_trip_seats = lock_booking_seats!(booking)
      new_trip_seats = lock_available_seats!(
        new_trip,
        old_trip_seats.size
      )

      validate_new_seats!(
        new_trip_seats,
        old_trip_seats.size
      )

      release_old_seats!(old_trip_seats)

      replace_booking_seats!(
        booking,
        new_trip_seats,
        new_trip
      )

      booking.update!(
        trip: new_trip,
        total_amount: new_trip_seats.sum { |trip_seat| new_trip.price },
        status: "rescheduled"
      )

      booking
    end

    # Send notification only after the reschedule transaction commits.
    SendBookingNotificationJob.perform_later(
      booking.id,
      "reschedule"
    )

    booking
  end

  private

  attr_reader :booking, :new_trip

  def validate_booking!(booking)
    unless booking.confirmed?
      raise ArgumentError, "Only confirmed bookings can be rescheduled"
    end
  end

  def validate_trip!(booking, new_trip)
    if booking.trip.from_city != new_trip.from_city ||
       booking.trip.to_city != new_trip.to_city
      raise ArgumentError,
            "Booking can only be rescheduled for the same route"
    end

    if booking.trip.operator_id != new_trip.operator_id
      raise ArgumentError,
            "Booking can only be rescheduled with the same operator"
    end

    if new_trip.departure_at <= Time.current
      raise ArgumentError,
            "New trip must be in the future"
    end
  end

  def lock_booking_seats!(booking)
    BookingSeat
      .where(booking: booking)
      .order(:id)
      .lock
      .includes(trip_seat: :seat)
      .to_a
      .map(&:trip_seat)
  end

  def lock_available_seats!(new_trip, seat_count)
    TripSeat
      .where(
        trip: new_trip,
        status: "available"
      )
      .order(:id)
      .lock
      .limit(seat_count)
      .to_a
  end

  def validate_new_seats!(trip_seats, expected_count)
    if trip_seats.size != expected_count
      raise SeatUnavailableError,
            "Not enough seats available on the selected trip"
    end
  end

  def release_old_seats!(trip_seats)
    TripSeat
      .where(id: trip_seats.map(&:id))
      .update_all(status: "available")
  end

  def replace_booking_seats!(booking, new_trip_seats, new_trip)
    booking.booking_seats.delete_all

    new_trip_seats.each do |trip_seat|
      booking.booking_seats.create!(
        trip_seat: trip_seat,
        price: new_trip.price
      )

      trip_seat.update!(status: "booked")
    end
  end
end