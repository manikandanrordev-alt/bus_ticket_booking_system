# frozen_string_literal: true

require "rails_helper"

RSpec.describe SeatHoldService do
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
      departure_at: 1.day.from_now,
      arrival_at: 1.day.from_now + 8.hours
    )
  end

  let!(:trip_seat_one) do
    create(
      :trip_seat,
      trip: trip,
      seat: seat_one,
      status: "available"
    )
  end

  let!(:trip_seat_two) do
    create(
      :trip_seat,
      trip: trip,
      seat: seat_two,
      status: "available"
    )
  end

  describe "#call" do
    it "does not allow another user to hold an already held seat" do
      first_user = user
      second_user = create(:user)

      described_class.new(
        user: first_user,
        trip: trip,
        trip_seat_ids: [trip_seat_one.id]
      ).call

      expect {
        described_class.new(
          user: second_user,
          trip: trip,
          trip_seat_ids: [trip_seat_one.id]
        ).call
      }.to raise_error(
        SeatUnavailableError,
        "One or more selected seats are no longer available"
      )

      expect(Hold.count).to eq(1)
      expect(trip_seat_one.reload).to be_held
    end
    
    it "creates a five-minute hold for selected seats" do
      hold = described_class.new(
        user: user,
        trip: trip,
        trip_seat_ids: [trip_seat_one.id, trip_seat_two.id]
      ).call

      expect(hold).to be_persisted
      expect(hold).to be_active
      expect(hold.user).to eq(user)

      expect(hold.expires_at)
        .to be_within(2.seconds)
        .of(5.minutes.from_now)

      expect(hold.trip_seats)
        .to contain_exactly(trip_seat_one, trip_seat_two)

      expect(trip_seat_one.reload).to be_held
      expect(trip_seat_two.reload).to be_held
    end

    it "does not allow an unavailable seat to be held" do
      trip_seat_one.update!(status: "booked")

      expect {
        described_class.new(
          user: user,
          trip: trip,
          trip_seat_ids: [trip_seat_one.id]
        ).call
      }.to raise_error(
        SeatUnavailableError,
        "One or more selected seats are no longer available"
      )

      expect(Hold.count).to eq(0)
    end

    it "does not allow a seat from another trip" do
      other_trip = create(
        :trip,
        operator: operator,
        bus: bus,
        departure_at: 2.days.from_now,
        arrival_at: 2.days.from_now + 8.hours
      )

      expect {
        described_class.new(
          user: user,
          trip: other_trip,
          trip_seat_ids: [trip_seat_one.id]
        ).call
      }.to raise_error(
        ArgumentError,
        "One or more selected seats do not belong to this trip"
      )

      expect(Hold.count).to eq(0)
    end

    it "does not create a hold when no seats are selected" do
      expect {
        described_class.new(
          user: user,
          trip: trip,
          trip_seat_ids: []
        ).call
      }.to raise_error(
        ArgumentError,
        "At least one seat must be selected"
      )

      expect(Hold.count).to eq(0)
    end

    it "does not partially create a hold when one selected seat is unavailable" do
      trip_seat_two.update!(status: "booked")

      expect {
        described_class.new(
          user: user,
          trip: trip,
          trip_seat_ids: [
            trip_seat_one.id,
            trip_seat_two.id
          ]
        ).call
      }.to raise_error(SeatUnavailableError)

      expect(Hold.count).to eq(0)
      expect(trip_seat_one.reload).to be_available
    end
  end
end