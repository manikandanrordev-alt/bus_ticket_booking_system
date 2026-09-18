# frozen_string_literal: true

class Hold < ApplicationRecord
  belongs_to :user

  has_many :hold_seats, dependent: :destroy
  has_many :trip_seats, through: :hold_seats

  enum :status, {
    active: "active",
    expired: "expired",
    converted: "converted",
    cancelled: "cancelled"
  }

  validates :expires_at, presence: true
  validates :status, presence: true

  scope :currently_active, -> {
    active.where("expires_at > ?", Time.current)
  }
end