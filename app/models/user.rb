class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  ROLES = %w[customer developer admin].freeze

  has_one :developer_profile, dependent: :destroy
  has_one :customer_profile, dependent: :destroy
  has_many :portfolio_submissions, dependent: :destroy

  validates :role, inclusion: { in: ROLES }

  after_create :create_role_profile

  def developer? = role == "developer"
  def customer?  = role == "customer"
  def admin?     = role == "admin"

  def profile
    developer? ? developer_profile : customer_profile
  end

  private

  def create_role_profile
    if developer?
      create_developer_profile!
    elsif customer?
      create_customer_profile!
    end
  end
end