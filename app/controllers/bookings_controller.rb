# frozen_string_literal: true

class BookingsController < ApplicationController
  before_action :authenticate_user!

  def show
    @booking = current_user.bookings.includes(
      booking_seats: { trip_seat: :seat }
    ).find(params[:id])
  end

  def cancel
    booking = current_user.bookings.find(params[:id])

    result = BookingCancellationService.new(
      booking: booking
    ).call

    redirect_to booking_path(booking),
      notice: "Booking cancelled. Refund amount: ₹#{result[:refund_amount]}"
  rescue ArgumentError => e
    redirect_to booking_path(booking), alert: e.message
  end
end