# frozen_string_literal: true

class SmsNotificationService
  def initialize(booking:, event:)
    @booking = booking
    @event = event
  end

  def call
    phone_number = booking.user.phone_number

    return if phone_number.blank?

    message = build_message

    Rails.logger.info(
      "[SMS] To: #{phone_number} | Message: #{message}"
    )

    if Rails.env.development?
      SmsMailer.with(phone_number: phone_number, message: message).sms_notification.deliver_now
    end
  end

  private

  attr_reader :booking, :event

  def build_message
    case event
    when "confirmation"
      confirmation_message
    when "cancellation"
      cancellation_message
    when "reschedule"
      reschedule_message
    else
      raise ArgumentError, "Unsupported SMS event: #{event}"
    end
  end

  def confirmation_message
    "Your booking ##{booking.id} is confirmed. " \
      "#{booking.trip.from_city} to #{booking.trip.to_city} " \
      "on #{booking.trip.departure_at.strftime('%d %b %Y at %I:%M %p')}."
  end

  def cancellation_message
    refund_amount = [
      booking.total_amount -
        BookingCancellationService::CANCELLATION_FEE,
      0
    ].max

    "Your booking ##{booking.id} has been cancelled. " \
      "Refund amount: INR #{format('%.2f', refund_amount)}."
  end

  def reschedule_message
    "Your booking ##{booking.id} has been rescheduled. " \
      "New trip: #{booking.trip.from_city} to #{booking.trip.to_city} " \
      "on #{booking.trip.departure_at.strftime('%d %b %Y at %I:%M %p')}."
  end
end