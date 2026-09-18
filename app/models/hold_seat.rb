# frozen_string_literal: true

class HoldSeat < ApplicationRecord
  belongs_to :hold
  belongs_to :trip_seat

  validates :trip_seat_id, uniqueness: { scope: :hold_id }
end