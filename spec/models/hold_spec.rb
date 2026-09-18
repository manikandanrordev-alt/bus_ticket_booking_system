require "rails_helper"

RSpec.describe Hold, type: :model do
  describe "validations" do
    it "requires expires_at" do
      hold = build(:hold, expires_at: nil)

      expect(hold).not_to be_valid
      expect(hold.errors[:expires_at]).to include("can't be blank")
    end
  end

  describe "status" do
    it "defaults to active" do
      hold = build(:hold)

      expect(hold.status).to eq("active")
    end
  end

  describe ".currently_active" do
    it "returns active holds that have not expired" do
      active_hold = create(:hold, expires_at: 2.minutes.from_now)
      create(:hold, expires_at: 2.minutes.ago)
      create(:hold, status: :converted, expires_at: 2.minutes.from_now)

      expect(Hold.currently_active).to contain_exactly(active_hold)
    end
  end
end