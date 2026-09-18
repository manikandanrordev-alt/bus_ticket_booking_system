# frozen_string_literal: true

class HoldExpiryService
  def initialize(hold)
    @hold = hold
  end

  def call
    ActiveRecord::Base.transaction do
      hold = Hold.lock.find(@hold.id)

      return hold unless hold.active?
      return hold if hold.expires_at > Time.current

      trip_seats = TripSeat
        .joins(:hold_seats)
        .where(hold_seats: { hold_id: hold.id })
        .order(:id)
        .lock

      trip_seats.update_all(status: "available")
      hold.update!(status: "expired")

      hold
    end
  end
end