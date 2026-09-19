# frozen_string_literal: true

class BookingMailerPreview < ActionMailer::Preview
  def confirmation
    booking = Booking.includes(
      :user,
      :trip,
      booking_seats: { trip_seat: :seat }
    ).first

    BookingMailer.confirmation(booking)
  end

  def cancellation
    booking = Booking.includes(
      :user,
      :trip,
      booking_seats: { trip_seat: :seat }
    ).first

    BookingMailer.cancellation(booking)
  end

  def reschedule
    booking = Booking.includes(
      :user,
      :trip,
      booking_seats: { trip_seat: :seat }
    ).first

    BookingMailer.reschedule(booking)
  end
end
