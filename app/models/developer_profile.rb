class DeveloperProfile < ApplicationRecord
  belongs_to :user
  has_paper_trail

  CONNECT_STATUSES      = %w[pending active restricted].freeze
  VERIFICATION_STATUSES = %w[unverified identity_verified approved].freeze
  ONBOARDING_STEPS      = { portfolio: 1, identity: 2, connect: 3, complete: 4 }.freeze

  validates :connect_onboarding_status, inclusion: { in: CONNECT_STATUSES }
  validates :verification_status,       inclusion: { in: VERIFICATION_STATUSES }

  def onboarding_step_name
    ONBOARDING_STEPS.key(onboarding_step) || :portfolio
  end

  def fully_verified?
    verification_status == "approved" && connect_onboarding_status == "active"
  end

  def listed? = fully_verified?
  def github_connected? = github_uid.present?

  def portfolio_submitted?
    user.portfolio_submissions.where(status: %w[pending approved]).exists?
  end

  def portfolio_approved?
    user.portfolio_submissions.where(status: "approved").exists?
  end
end