# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExpireHoldJob, type: :job do
  let!(:user) { create(:user) }
  let!(:hold) { create(:hold, user: user) }

  it "calls HoldExpiryService for the hold" do
    expect(HoldExpiryService)
      .to receive(:new)
      .with(hold)
      .and_call_original

    described_class.perform_now(hold.id)
  end

  it "does nothing when the hold does not exist" do
    expect(HoldExpiryService).not_to receive(:new)

    described_class.perform_now(-1)
  end
end