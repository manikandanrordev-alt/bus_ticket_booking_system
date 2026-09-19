# frozen_string_literal: true

class SendBookingNotificationJob < ApplicationJob
  queue_as :default

  EVENTS = %w[
    confirmation
    cancellation
    reschedule
  ].freeze

  def perform(booking_id, event)
    unless EVENTS.include?(event)
      raise ArgumentError, "Unsupported booking notification event: #{event}"
    end

    booking = Booking.find(booking_id)

    BookingMailer
      .public_send(event, booking)
      .deliver_now

    SmsNotificationService
      .new(booking: booking, event: event)
      .call
  end
end