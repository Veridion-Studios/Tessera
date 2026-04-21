class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_paper_trail

  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles
  has_many :passkeys, dependent: :destroy
  has_many :portfolio_submissions, dependent: :destroy
  has_one  :developer_profile, dependent: :destroy
  has_one  :customer_profile,  dependent: :destroy

  attr_writer :initial_role

  before_create :set_webauthn_id
  after_create  :assign_initial_role
  after_create  :create_initial_profiles

  # --- Role helpers ---

  def has_role?(role)
    roles.exists?(name: role.to_s)
  end

  def add_role!(role)
    r = Role.find_or_create_by!(name: role.to_s)
    user_roles.find_or_create_by!(role: r)
  end

  def role_names
    roles.pluck(:name)
  end

  def developer? = has_role?(:developer)
  def customer?  = has_role?(:customer)
  def admin?     = has_role?(:admin)

  def multi_role?
    roles.where(name: %w[developer customer]).count > 1
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

  # --- Identity ---

  def identity_verified?
    identity_status == "verified"
  end

  private

  def set_webauthn_id
    self.webauthn_id ||= WebAuthn.generate_user_id
  end

  def assign_initial_role
    add_role!(@initial_role) if @initial_role.present?
  end

  def create_initial_profiles
    create_developer_profile! if developer?
    create_customer_profile!  if customer?
  end
end