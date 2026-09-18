# frozen_string_literal: true

class BookingConfirmationService
  def initialize(hold:, idempotency_key:)
    @hold = hold
    @idempotency_key = idempotency_key
  end

  def call
    existing_booking = Booking.find_by(idempotency_key: idempotency_key)
    return existing_booking if existing_booking

    ActiveRecord::Base.transaction do
      hold = Hold.lock.find(@hold.id)

      existing_booking = Booking.find_by(idempotency_key: idempotency_key)
      return existing_booking if existing_booking

      validate_hold!(hold)

      trip_seats = lock_trip_seats!(hold)

      validate_trip_seats!(trip_seats)

      booking = create_booking!(hold, trip_seats)

      create_booking_seats!(booking, trip_seats)

      trip_seats.each do |trip_seat|
        trip_seat.update!(status: "booked")
      end

      hold.update!(status: "converted")

      booking
    end
  end

  private

  attr_reader :hold, :idempotency_key

  def validate_hold!(hold)
    unless hold.active?
      raise ArgumentError, "Hold is no longer active"
    end

    if hold.expires_at <= Time.current
      raise ArgumentError, "Hold has expired"
    end
  end

  def lock_trip_seats!(hold)
    TripSeat
      .joins(:hold_seats)
      .where(hold_seats: { hold_id: hold.id })
      .order("trip_seats.id")
      .lock
      .to_a
  end

  def validate_trip_seats!(trip_seats)
    return if trip_seats.all?(&:held?)

    raise SeatUnavailableError, "One or more held seats are no longer available"
  end

  def create_booking!(hold, trip_seats)
    Booking.create!(
      user: hold.user,
      trip: hold.trip_seats.first.trip,
      hold: hold,
      total_amount: trip_seats.sum { |trip_seat| trip_seat.trip.price },
      status: "confirmed",
      idempotency_key: idempotency_key
    )
  end

  def create_booking_seats!(booking, trip_seats)
    trip_seats.each do |trip_seat|
      booking.booking_seats.create!(
        trip_seat: trip_seat,
        price: trip_seat.trip.price
      )
    end
  end
end