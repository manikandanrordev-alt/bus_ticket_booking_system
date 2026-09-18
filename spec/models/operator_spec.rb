require "rails_helper"

RSpec.describe Operator, type: :model do
  describe "validations" do
    it "is valid with a name and rating between 0 and 5" do
      operator = build(:operator, rating: 4.5)

      expect(operator).to be_valid
    end

    it "requires a name" do
      operator = build(:operator, name: nil)

      expect(operator).not_to be_valid
      expect(operator.errors[:name]).to include("can't be blank")
    end

    it "requires rating to be between 0 and 5" do
      operator = build(:operator, rating: 6)

      expect(operator).not_to be_valid
    end
  end

  describe "associations" do
    it "has many buses" do
      association = described_class.reflect_on_association(:buses)

      expect(association.macro).to eq(:has_many)
    end

    it "has many trips" do
      association = described_class.reflect_on_association(:trips)

      expect(association.macro).to eq(:has_many)
    end
  end
end