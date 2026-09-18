# frozen_string_literal: true

class HoldsController < ApplicationController
  before_action :authenticate_user!

  def create
    trip = Trip.find(params[:trip_id])

    hold = SeatHoldService.new(
      user: current_user,
      trip: trip,
      trip_seat_ids: params[:trip_seat_ids]
    ).call

    redirect_to hold_path(hold), notice: "Seats held for 5 minutes."
  rescue SeatUnavailableError, ArgumentError => e
    redirect_to trip_seats_path(trip), alert: e.message
  end

  def show
    @hold = current_user.holds.includes(
      hold_seats: { trip_seat: :seat }
    ).find(params[:id])
  end

  def confirm
    @hold = current_user.holds.find(params[:id])

    booking = BookingConfirmationService.new(
      hold: @hold,
      idempotency_key: params[:idempotency_key]
    ).call

    redirect_to booking_path(booking), notice: "Booking confirmed successfully."
  rescue SeatUnavailableError, ArgumentError => e
    redirect_to hold_path(@hold), alert: e.message
  end
end