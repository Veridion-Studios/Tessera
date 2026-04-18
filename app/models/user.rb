class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  ROLES = %w[customer developer admin].freeze

  has_one  :developer_profile, dependent: :destroy
  has_one  :customer_profile,  dependent: :destroy
  has_many :portfolio_submissions, dependent: :destroy

  validates :roles, presence: true

  after_create :create_initial_profiles

  def has_role?(role)
    roles.include?(role.to_s)
  end

  def developer? = has_role?(:developer)
  def customer?  = has_role?(:customer)
  def admin?     = has_role?(:admin)

  def multi_role?
    (roles & %w[developer customer]).length > 1
  end

  # A user can add the developer role if they're already a verified customer
  def can_add_developer_role?
    customer? && !developer? && customer_profile&.verified?
  end

  # A user can add the customer role freely once they exist
  def can_add_customer_role?
    developer? && !customer?
  end

  def developer_onboarding_complete?
    developer_profile&.fully_verified?
  end

  private

  def create_initial_profiles
    create_developer_profile! if developer?
    create_customer_profile!  if customer?
  end
end