# frozen_string_literal: true

class ExpireHoldJob < ApplicationJob
  queue_as :default

  def perform(hold_id)
    hold = Hold.find_by(id: hold_id)
    return unless hold

    HoldExpiryService.new(hold).call
  end
end