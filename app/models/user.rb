class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  ROLES = %w[customer developer admin].freeze

  validates :role, inclusion: { in: ROLES }

  def developer? = role == "developer"
  def customer?  = role == "customer"
  def admin?     = role == "admin"
end