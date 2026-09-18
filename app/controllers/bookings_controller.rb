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

  def reschedule
    booking = current_user.bookings.find(params[:id])
    new_trip = Trip.find(params[:trip_id])

    BookingRescheduleService.new(
      booking: booking,
      new_trip: new_trip
    ).call

    redirect_to booking_path(booking),
      notice: "Booking rescheduled successfully."
  rescue ArgumentError, SeatUnavailableError => e
    redirect_to booking_path(booking), alert: e.message
  end

  def reschedule_form
    @booking = current_user.bookings.find(params[:id])

    @trips = TripSearchService.new(
      from_city: @booking.trip.from_city,
      to_city: @booking.trip.to_city
    ).call
      .where(operator_id: @booking.trip.operator_id)
      .where("departure_at > ?", Time.current)
      .where.not(id: @booking.trip_id)
  end
end