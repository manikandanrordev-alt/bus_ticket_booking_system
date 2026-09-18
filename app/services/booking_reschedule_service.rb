# frozen_string_literal: true

class BookingRescheduleService
  def initialize(booking:, new_trip:)
    @booking = booking
    @new_trip = new_trip
  end

  def call
    ActiveRecord::Base.transaction do
      booking = Booking.lock.find(@booking.id)
      new_trip = Trip.lock.find(@new_trip.id)

      validate_booking!(booking)
      validate_trip!(booking, new_trip)

      old_trip_seats = lock_booking_seats!(booking)
      new_trip_seats = lock_available_seats!(new_trip, old_trip_seats.size)

      validate_new_seats!(new_trip_seats, old_trip_seats.size)

      release_old_seats!(old_trip_seats)
      replace_booking_seats!(booking, new_trip_seats, new_trip)

      booking.update!(
        trip: new_trip,
        total_amount: new_trip_seats.sum { |trip_seat| new_trip.price },
        status: "rescheduled"
      )

      booking
    end
  end

  private

  attr_reader :booking, :new_trip

  def validate_booking!(booking)
    return if booking.confirmed?

    raise ArgumentError, "Only confirmed bookings can be rescheduled"
  end

  def validate_trip!(booking, new_trip)
    unless booking.trip.operator_id == new_trip.operator_id
      raise ArgumentError, "Rescheduled trip must use the same operator"
    end

    unless booking.trip.from_city == new_trip.from_city &&
           booking.trip.to_city == new_trip.to_city
      raise ArgumentError, "Rescheduled trip must use the same route"
    end

    if new_trip.departure_at <= Time.current
      raise ArgumentError, "Rescheduled trip must be in the future"
    end

    if new_trip.id == booking.trip_id
      raise ArgumentError, "Please select a different trip"
    end
  end

  def lock_booking_seats!(booking)
    BookingSeat
      .where(booking: booking)
      .order(:id)
      .lock
      .includes(:trip_seat)
      .map(&:trip_seat)
  end

  def lock_available_seats!(trip, seat_count)
    TripSeat
      .where(trip: trip, status: "available")
      .order(:id)
      .lock
      .limit(seat_count)
      .to_a
  end

  def validate_new_seats!(trip_seats, required_count)
    return if trip_seats.size == required_count

    raise SeatUnavailableError,
      "Not enough seats are available on the selected trip"
  end

  def release_old_seats!(trip_seats)
    TripSeat
      .where(id: trip_seats.map(&:id))
      .update_all(status: "available")
  end

  def replace_booking_seats!(booking, trip_seats, trip)
    booking.booking_seats.destroy_all

    trip_seats.each do |trip_seat|
      booking.booking_seats.create!(
        trip_seat: trip_seat,
        price: trip.price
      )

      trip_seat.update!(status: "booked")
    end
  end
end
