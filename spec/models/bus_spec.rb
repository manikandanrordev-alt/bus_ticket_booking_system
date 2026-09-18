require "rails_helper"

RSpec.describe Bus, type: :model do
  describe "validations" do
    it "is valid with required attributes" do
      bus = build(:bus)

      expect(bus).to be_valid
    end

    it "requires a name" do
      bus = build(:bus, name: nil)

      expect(bus).not_to be_valid
      expect(bus.errors[:name]).to include("can't be blank")
    end

    it "requires a bus type" do
      bus = build(:bus, bus_type: nil)

      expect(bus).not_to be_valid
      expect(bus.errors[:bus_type]).to include("can't be blank")
    end
  end

  describe "associations" do
    it "belongs to an operator" do
      association = described_class.reflect_on_association(:operator)

      expect(association.macro).to eq(:belongs_to)
    end

    it "has many seats" do
      association = described_class.reflect_on_association(:seats)

      expect(association.macro).to eq(:has_many)
    end

    it "has many amenities through bus amenities" do
      association = described_class.reflect_on_association(:amenities)

      expect(association.macro).to eq(:has_many)
    end
  end
end