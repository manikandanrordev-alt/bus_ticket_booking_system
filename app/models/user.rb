class User < ApplicationRecord
  has_secure_password

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :email, presence: true
  validates :email, uniqueness: true

end