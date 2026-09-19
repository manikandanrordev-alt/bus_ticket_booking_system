# frozen_string_literal: true

class BookingMailer < ApplicationMailer
  default from: "notifications@ticketbooking.example"

  def confirmation(booking)
    @booking = load_booking(booking)

    mail(
      to: @booking.user.email,
      subject: "Booking Confirmed - ##{@booking.id}"
    )
  end

  def cancellation(booking)
    @booking = load_booking(booking)

    @ticket_amount = @booking.total_amount
    @cancellation_fee = BookingCancellationService::CANCELLATION_FEE
    @refund_amount = [
      @ticket_amount - @cancellation_fee,
      0
    ].max

    mail(
      to: @booking.user.email,
      subject: "Booking Cancelled - ##{@booking.id}"
    )
  end

  def reschedule(booking)
    @booking = load_booking(booking)

    mail(
      to: @booking.user.email,
      subject: "Booking Rescheduled - ##{@booking.id}"
    )
  end

  private

  def load_booking(booking)
    Booking
      .includes(
        :user,
        :trip,
        { booking_seats: { trip_seat: :seat } }
      )
      .find(booking.id)
  end
end