class DeveloperProfile < ApplicationRecord
  belongs_to :user
  has_paper_trail

  GITHUB_ACCESS_TOKEN_ENCRYPTION_CONTEXT = "developer_profile.github_access_token"

  CONNECT_STATUSES      = %w[pending active restricted].freeze
  VERIFICATION_STATUSES = %w[unverified identity_verified approved].freeze
  # Corrected to match new onboarding order
  ONBOARDING_STEPS      = { identity: 1, portfolio: 2, connect: 3, complete: 4 }.freeze

  validates :connect_onboarding_status, inclusion: { in: CONNECT_STATUSES }
  validates :verification_status,       inclusion: { in: VERIFICATION_STATUSES }

  def onboarding_step_name
    ONBOARDING_STEPS.key(onboarding_step) || :identity
  end

  def fully_verified?
    verification_status == "approved" && connect_onboarding_status == "active"
  end

  def listed?            = fully_verified?
  def github_connected?  = github_uid.present?

  def github_access_token
    encrypted_token = self[:github_access_token]
    return if encrypted_token.blank?

    decrypt_github_access_token(encrypted_token)
  rescue ActiveSupport::MessageEncryptor::InvalidMessage, ArgumentError
    encrypted_token
  end

  def github_access_token=(value)
    self[:github_access_token] = if value.present?
      encrypt_github_access_token(value)
    else
      value
    end
  end

  def portfolio_submitted?
    user.portfolio_submissions.where(status: %w[pending approved]).exists?
  end

  def portfolio_approved?
    user.portfolio_submissions.where(status: "approved").exists?
  end

  private

  def github_access_token_encryptor
    key = Rails.application.key_generator.generate_key(GITHUB_ACCESS_TOKEN_ENCRYPTION_CONTEXT, 32)
    ActiveSupport::MessageEncryptor.new(key)
  end

  def encrypt_github_access_token(value)
    github_access_token_encryptor.encrypt_and_sign(value)
  end

  def decrypt_github_access_token(value)
    github_access_token_encryptor.decrypt_and_verify(value)
  end
end