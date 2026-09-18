require "rails_helper"

RSpec.describe Amenity, type: :model do
  describe "validations" do
    it "is valid with a name" do
      amenity = build(:amenity)

      expect(amenity).to be_valid
    end

    it "requires a name" do
      amenity = build(:amenity, name: nil)

      expect(amenity).not_to be_valid
    end

    it "does not allow duplicate names" do
      create(:amenity, name: "Wi-Fi")

      duplicate = build(:amenity, name: "Wi-Fi")

      expect(duplicate).not_to be_valid
    end
  end

  describe "associations" do
    it "has many buses through bus amenities" do
      association = described_class.reflect_on_association(:buses)

      expect(association.macro).to eq(:has_many)
    end
  end
end