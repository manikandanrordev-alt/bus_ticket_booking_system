require "rails_helper"

RSpec.describe HoldSeat, type: :model do
  describe "associations" do
    it "belongs to a hold" do
      association = described_class.reflect_on_association(:hold)

      expect(association.macro).to eq(:belongs_to)
    end

    it "belongs to a trip seat" do
      association = described_class.reflect_on_association(:trip_seat)

      expect(association.macro).to eq(:belongs_to)
    end
  end

  describe "validations" do
    it "does not allow the same trip seat twice in the same hold" do
      trip = create(:trip)
      seat = create(:seat, bus: trip.bus)

      trip_seat = create(
        :trip_seat,
        trip: trip,
        seat: seat
      )

      hold = create(:hold)

      create(
        :hold_seat,
        hold: hold,
        trip_seat: trip_seat
      )

      duplicate = build(
        :hold_seat,
        hold: hold,
        trip_seat: trip_seat
      )

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:trip_seat_id]).to include(
        "has already been taken"
      )
    end
  end
end
