class BusAmenity < ApplicationRecord
  belongs_to :bus
  belongs_to :amenity

  validates :amenity_id, uniqueness: { scope: :bus_id }
end