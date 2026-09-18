require "rails_helper"

RSpec.describe Seat, type: :model do
  describe "validations" do
    it "is valid with required attributes" do
      seat = build(:seat)

      expect(seat).to be_valid
    end

    it "requires a seat number" do
      seat = build(:seat, seat_number: nil)

      expect(seat).not_to be_valid
    end

    it "requires a seat type" do
      seat = build(:seat, seat_type: nil)

      expect(seat).not_to be_valid
    end

    it "does not allow duplicate seat numbers on the same bus" do
      bus = create(:bus)

      create(:seat, bus: bus, seat_number: "A1")

      duplicate = build(:seat, bus: bus, seat_number: "A1")

      expect(duplicate).not_to be_valid
    end
  end

  describe "associations" do
    it "belongs to a bus" do
      association = described_class.reflect_on_association(:bus)

      expect(association.macro).to eq(:belongs_to)
    end
  end
end