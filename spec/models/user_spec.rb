require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    it "is invalid without an email" do
      user = User.new(email: nil)

      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it "is invalid when the email is already registered" do
      create(:user, email: "mani@example.com")

      user = build(:user, email: "mani@example.com")
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("has already been taken")
    end

    it "normalizes the email to lowercase" do
      user = User.create!(email: "MANI@EXAMPLE.COM")
      expect(user.email).to eq("mani@example.com")
    end

    it "removes leading and trailing spaces from email" do
      user = User.create!(email: "  mani@example.com  ")
      expect(user.email).to eq("mani@example.com")
    end
  end
end