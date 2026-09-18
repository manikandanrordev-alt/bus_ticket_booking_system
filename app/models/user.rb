class User < ApplicationRecord
  normalizes :email, with: ->(email) { email.strip.downcase }

  has_many :holds, dependent: :restrict_with_error
  has_many :bookings, dependent: :restrict_with_error

  validates :email, presence: true, uniqueness: true
end