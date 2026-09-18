# frozen_string_literal: true

class SeatHoldService
  HOLD_DURATION = 5.minutes

  def initialize(user:, trip:, trip_seat_ids:)
    @user = user
    @trip = trip
    @trip_seat_ids = Array(trip_seat_ids).map(&:to_i).uniq
  end

  def call
    validate_request!

    ActiveRecord::Base.transaction do
      trip_seats = lock_trip_seats!

      validate_trip_seats!(trip_seats)

      hold = create_hold!

      create_hold_seats!(hold, trip_seats)

      ExpireHoldJob.set(wait_until: hold.expires_at).perform_later(hold.id)

      mark_seats_as_held!(trip_seats)

      hold
    end
  end

  private

  attr_reader :user, :trip, :trip_seat_ids

  def validate_request!
    raise ArgumentError, "At least one seat must be selected" if trip_seat_ids.empty?

    return if trip_seat_ids.all? { |id| id.to_s.match?(/\A\d+\z/) }

    raise ArgumentError, "Invalid seat selection"
  end

  def lock_trip_seats!
    TripSeat
      .where(trip: trip, id: trip_seat_ids)
      .order(:id)
      .lock
      .to_a
  end

  def validate_trip_seats!(trip_seats)
    if trip_seats.size != trip_seat_ids.size
      raise ArgumentError, "One or more selected seats do not belong to this trip"
    end

    unavailable_seats = trip_seats.reject(&:available?)

    return if unavailable_seats.empty?

    raise SeatUnavailableError, "One or more selected seats are no longer available"
  end

  def create_hold!
    Hold.create!(
      user: user,
      expires_at: HOLD_DURATION.from_now,
      status: "active"
    )
  end

  def create_hold_seats!(hold, trip_seats)
    trip_seats.each do |trip_seat|
      hold.hold_seats.create!(
        trip_seat: trip_seat
      )
    end
  end

  def mark_seats_as_held!(trip_seats)
    TripSeat
      .where(id: trip_seats.map(&:id))
      .update_all(status: "held")
  end
end