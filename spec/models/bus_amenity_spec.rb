require "rails_helper"

RSpec.describe BusAmenity, type: :model do
  describe "associations" do
    it "belongs to a bus" do
      association = described_class.reflect_on_association(:bus)

      expect(association.macro).to eq(:belongs_to)
    end

    it "belongs to an amenity" do
      association = described_class.reflect_on_association(:amenity)

      expect(association.macro).to eq(:belongs_to)
    end
  end

  describe "validations" do
    it "does not allow the same amenity to be added to a bus twice" do
      bus = create(:bus)
      amenity = create(:amenity)

      create(:bus_amenity, bus: bus, amenity: amenity)

      duplicate = build(:bus_amenity, bus: bus, amenity: amenity)

      expect(duplicate).not_to be_valid
    end
  end
end