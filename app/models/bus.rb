class Bus < ApplicationRecord
  belongs_to :operator

  has_many :seats, dependent: :destroy
  has_many :bus_amenities, dependent: :destroy
  has_many :amenities, through: :bus_amenities
  has_many :trips, dependent: :restrict_with_error

  enum :bus_type, {
    ac: "ac",
    non_ac: "non_ac"
  }

  validates :name, presence: true
  validates :bus_type, presence: true
end