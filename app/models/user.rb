class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  ROLES = %w[customer developer admin].freeze

  has_many :passkeys, dependent: :destroy
  has_many :portfolio_submissions, dependent: :destroy
  has_one  :developer_profile, dependent: :destroy
  has_one  :customer_profile,  dependent: :destroy

  validates :roles, presence: true

  before_create :set_webauthn_id
  after_create  :create_initial_profiles

  def has_role?(role)
    roles.include?(role.to_s)
  end

  def developer? = has_role?(:developer)
  def customer?  = has_role?(:customer)
  def admin?     = has_role?(:admin)

  def multi_role?
    (roles & %w[developer customer]).length > 1
  end

  def can_add_developer_role?
    customer? && !developer? && customer_profile&.verified?
  end

  def can_add_customer_role?
    developer? && !customer?
  end

  def developer_onboarding_complete?
    developer_profile&.fully_verified?
  end

  private

  def set_webauthn_id
    self.webauthn_id ||= WebAuthn.generate_user_id
  end

  def create_initial_profiles
    create_developer_profile! if developer?
    create_customer_profile!  if customer?
  end
end