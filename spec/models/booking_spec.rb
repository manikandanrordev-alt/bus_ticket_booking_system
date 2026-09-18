# frozen_string_literal: true

require "rails_helper"

RSpec.describe Booking, type: :model do
  describe "validations" do
    it "requires a unique idempotency key" do
      user = create(:user)
      trip = create(:trip)
      hold = create(:hold, user: user)

      create(
        :booking,
        user: user,
        trip: trip,
        hold: hold,
        idempotency_key: "duplicate-key"
      )

      duplicate = build(
        :booking,
        user: user,
        trip: trip,
        hold: hold,
        idempotency_key: "duplicate-key"
      )

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:idempotency_key])
        .to include("has already been taken")
    end

    it "does not allow a negative total amount" do
      booking = build(:booking, total_amount: -1)

      expect(booking).not_to be_valid
      expect(booking.errors[:total_amount])
        .to include("must be greater than or equal to 0")
    end
  end
end