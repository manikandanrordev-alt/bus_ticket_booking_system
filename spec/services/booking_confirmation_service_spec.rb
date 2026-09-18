# frozen_string_literal: true

require "rails_helper"

RSpec.describe BookingConfirmationService do
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
      status: "held"
    )
  end

  let!(:trip_seat_two) do
    create(
      :trip_seat,
      trip: trip,
      seat: seat_two,
      status: "held"
    )
  end

  let!(:hold) do
    create(
      :hold,
      user: user,
      expires_at: 5.minutes.from_now,
      status: "active"
    )
  end

  before do
    create(
      :hold_seat,
      hold: hold,
      trip_seat: trip_seat_one
    )

    create(
      :hold_seat,
      hold: hold,
      trip_seat: trip_seat_two
    )
  end

  describe "#call" do
    it "confirms an active hold and books its seats" do
      booking = described_class.new(
        hold: hold,
        idempotency_key: "confirm-#{hold.id}"
      ).call

      expect(booking).to be_persisted
      expect(booking).to be_confirmed
      expect(booking.user).to eq(user)
      expect(booking.trip).to eq(trip)
      expect(booking.hold).to eq(hold)

      expect(booking.total_amount).to eq(1500.00)

      expect(booking.booking_seats.map(&:trip_seat))
        .to contain_exactly(trip_seat_one, trip_seat_two)

      expect(trip_seat_one.reload).to be_booked
      expect(trip_seat_two.reload).to be_booked

      expect(hold.reload).to be_converted
    end

    it "does not confirm an expired hold" do
      hold.update!(expires_at: 1.minute.ago)

      expect {
        described_class.new(
          hold: hold,
          idempotency_key: "confirm-#{hold.id}"
        ).call
      }.to raise_error(
        ArgumentError,
        "Hold has expired"
      )

      expect(Booking.count).to eq(0)
      expect(hold.reload).to be_active
    end

    it "does not confirm a hold that is no longer active" do
      hold.update!(status: "converted")

      expect {
        described_class.new(
          hold: hold,
          idempotency_key: "confirm-#{hold.id}"
        ).call
      }.to raise_error(
        ArgumentError,
        "Hold is no longer active"
      )

      expect(Booking.count).to eq(0)
    end

    it "returns the existing booking when the same idempotency key is reused" do
      service = described_class.new(
        hold: hold,
        idempotency_key: "same-key"
      )

      first_booking = service.call

      second_booking = described_class.new(
        hold: hold,
        idempotency_key: "same-key"
      ).call

      expect(second_booking).to eq(first_booking)
      expect(Booking.count).to eq(1)
    end
  end
end