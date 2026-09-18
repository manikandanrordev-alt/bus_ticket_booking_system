require "rails_helper"

RSpec.describe Trip, type: :model do
  describe "validations" do
    it "is valid with valid trip details" do
      operator = create(:operator)
      bus = create(:bus, operator: operator)

      trip = build(
        :trip,
        operator: operator,
        bus: bus
      )

      expect(trip).to be_valid
    end

    it "requires departure and arrival cities" do
      trip = build(:trip, from_city: nil, to_city: nil)

      expect(trip).not_to be_valid
    end

    it "does not allow a negative price" do
      trip = build(:trip, price: -100)

      expect(trip).not_to be_valid
    end

    it "requires arrival to be after departure" do
      departure = 2.hours.from_now

      trip = build(
        :trip,
        departure_at: departure,
        arrival_at: departure - 1.hour
      )

      expect(trip).not_to be_valid
      expect(trip.errors[:arrival_at]).to include("must be after departure")
    end

    it "does not allow a bus from another operator" do
      operator = create(:operator)
      other_operator = create(:operator)
      bus = create(:bus, operator: other_operator)

      trip = build(
        :trip,
        operator: operator,
        bus: bus
      )

      expect(trip).not_to be_valid
      expect(trip.errors[:bus]).to include(
        "must belong to the selected operator"
      )
    end
  end

  describe "associations" do
    it "belongs to an operator" do
      association = described_class.reflect_on_association(:operator)

      expect(association.macro).to eq(:belongs_to)
    end

    it "belongs to a bus" do
      association = described_class.reflect_on_association(:bus)

      expect(association.macro).to eq(:belongs_to)
    end

    it "has many trip seats" do
      association = described_class.reflect_on_association(:trip_seats)

      expect(association.macro).to eq(:has_many)
    end
  end
end