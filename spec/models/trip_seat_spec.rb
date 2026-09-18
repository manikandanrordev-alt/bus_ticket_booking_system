require "rails_helper"

RSpec.describe TripSeat, type: :model do
  describe "validations" do
    it "is valid when the seat belongs to the trip bus" do
      bus = create(:bus)
      seat = create(:seat, bus: bus)
      trip = create(:trip, bus: bus, operator: bus.operator)

      trip_seat = build(
        :trip_seat,
        trip: trip,
        seat: seat,
        status: "available"
      )

      expect(trip_seat).to be_valid
    end

    it "does not allow a seat from another bus" do
      bus = create(:bus)
      other_bus = create(:bus)

      seat = create(:seat, bus: other_bus)
      trip = create(:trip, bus: bus, operator: bus.operator)

      trip_seat = build(
        :trip_seat,
        trip: trip,
        seat: seat
      )

      expect(trip_seat).not_to be_valid
      expect(trip_seat.errors[:seat]).to include(
        "must belong to the trip bus"
      )
    end

    it "does not allow the same seat twice for a trip" do
      bus = create(:bus)
      seat = create(:seat, bus: bus)
      trip = create(:trip, bus: bus, operator: bus.operator)

      create(
        :trip_seat,
        trip: trip,
        seat: seat
      )

      duplicate = build(
        :trip_seat,
        trip: trip,
        seat: seat
      )

      expect(duplicate).not_to be_valid
    end
  end

  describe "status" do
    it "supports available status" do
      trip_seat = build(:trip_seat, status: "available")

      expect(trip_seat).to be_available
    end

    it "supports held status" do
      trip_seat = build(:trip_seat, status: "held")

      expect(trip_seat).to be_held
    end

    it "supports booked status" do
      trip_seat = build(:trip_seat, status: "booked")

      expect(trip_seat).to be_booked
    end
  end
end