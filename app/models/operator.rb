class Operator < ApplicationRecord
  has_many :buses, dependent: :restrict_with_error
  has_many :trips, dependent: :restrict_with_error

  validates :name, presence: true
  validates :rating, numericality: { in: 0..5 }
end