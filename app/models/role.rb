class Role < ApplicationRecord
  VALID = %w[customer developer admin].freeze

  has_many :user_roles, dependent: :destroy
  has_many :users, through: :user_roles

  validates :name, inclusion: { in: VALID }, uniqueness: true
end