# frozen_string_literal: true

require "rails_helper"

RSpec.describe BookingCancellationService do
  let!(:user) { create(:user) }

  let!(:operator) { create(:operator) }

  let!(:bus) do
    create(
      :bus,
      operator: operator,
      bus_type: "ac"
    )
  end

  let!(:seat_one) do
    create(
      :seat,
      bus: bus,
      seat_number: "A1",
      seat_type: "seater"
    )
  end

  let!(:seat_two) do
    create(
      :seat,
      bus: bus,
      seat_number: "A2",
      seat_type: "seater"
    )
  end

  let!(:trip) do
    create(
      :trip,
      operator: operator,
      bus: bus,
      price: 750.00,
      departure_at: 1.day.from_now,
      arrival_at: 1.day.from_now + 8.hours
    )
  end

  let!(:trip_seat_one) do
    create(
      :trip_seat,
      trip: trip,
      seat: seat_one,
      status: "booked"
    )
  end

  let!(:trip_seat_two) do
    create(
      :trip_seat,
      trip: trip,
      seat: seat_two,
      status: "booked"
    )
  end

  let!(:hold) do
    create(
      :hold,
      user: user,
      expires_at: 5.minutes.ago,
      status: "converted"
    )
  end

  let!(:booking) do
    create(
      :booking,
      user: user,
      trip: trip,
      hold: hold,
      total_amount: 1500.00,
      status: "confirmed"
    )
  end

  before do
    create(
      :booking_seat,
      booking: booking,
      trip_seat: trip_seat_one,
      price: 750.00
    )

    create(
      :booking_seat,
      booking: booking,
      trip_seat: trip_seat_two,
      price: 750.00
    )
  end

  describe "#call" do
    it "cancels the booking and releases the seats" do
      result = described_class.new(
        booking: booking
      ).call

      expect(result[:booking]).to be_cancelled
      expect(result[:refund_amount]).to eq(1450.00)

      expect(trip_seat_one.reload).to be_available
      expect(trip_seat_two.reload).to be_available
    end

    it "does not cancel within one hour of departure" do
      trip.update!(
        departure_at: 30.minutes.from_now
      )

      expect {
        described_class.new(
          booking: booking
        ).call
      }.to raise_error(
        ArgumentError,
        "Booking can only be cancelled at least 1 hour before departure"
      )

      expect(booking.reload).to be_confirmed
      expect(trip_seat_one.reload).to be_booked
      expect(trip_seat_two.reload).to be_booked
    end

    it "does not cancel an already cancelled booking" do
      booking.update!(status: "cancelled")

      expect {
        described_class.new(
          booking: booking
        ).call
      }.to raise_error(
        ArgumentError,
        "Booking is no longer active"
      )
    end

    it "does not refund below zero" do
      booking.update!(total_amount: 25.00)

      result = described_class.new(
        booking: booking
      ).call

      expect(result[:refund_amount]).to eq(0)
      expect(booking.reload).to be_cancelled
    end
  end
end
