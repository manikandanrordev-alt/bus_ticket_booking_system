# frozen_string_literal: true

require "rails_helper"

RSpec.describe HoldExpiryService do
  let!(:user) { create(:user) }

  let!(:operator) { create(:operator) }

  let!(:bus) do
    create(
      :bus,
      operator: operator,
      bus_type: "ac"
    )
  end

  let!(:seat) do
    create(
      :seat,
      bus: bus,
      seat_number: "A1",
      seat_type: "seater"
    )
  end

  let!(:trip) do
    create(
      :trip,
      operator: operator,
      bus: bus,
      departure_at: 1.day.from_now,
      arrival_at: 1.day.from_now + 8.hours
    )
  end

  let!(:trip_seat) do
    create(
      :trip_seat,
      trip: trip,
      seat: seat,
      status: "held"
    )
  end

  describe "#call" do
    it "expires an expired hold and releases its seats" do
      hold = create(
        :hold,
        user: user,
        expires_at: 1.minute.ago,
        status: "active"
      )

      create(
        :hold_seat,
        hold: hold,
        trip_seat: trip_seat
      )

      described_class.new(hold).call

      expect(hold.reload).to be_expired
      expect(trip_seat.reload).to be_available
    end

    it "does not expire an active hold that has not expired yet" do
      hold = create(
        :hold,
        user: user,
        expires_at: 1.minute.from_now,
        status: "active"
      )

      create(
        :hold_seat,
        hold: hold,
        trip_seat: trip_seat
      )

      described_class.new(hold).call

      expect(hold.reload).to be_active
      expect(trip_seat.reload).to be_held
    end

    it "does not change a hold that is no longer active" do
      hold = create(
        :hold,
        user: user,
        expires_at: 1.minute.ago,
        status: "converted"
      )

      create(
        :hold_seat,
        hold: hold,
        trip_seat: trip_seat
      )

      described_class.new(hold).call

      expect(hold.reload).to be_converted
      expect(trip_seat.reload).to be_held
    end
  end
end