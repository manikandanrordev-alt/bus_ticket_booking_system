class Amenity < ApplicationRecord
  has_many :bus_amenities, dependent: :destroy
  has_many :buses, through: :bus_amenities

  validates :name, presence: true, uniqueness: true
end