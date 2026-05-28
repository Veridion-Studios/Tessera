class DeveloperProfile < ApplicationRecord
  belongs_to :user
  has_paper_trail

  GITHUB_ACCESS_TOKEN_ENCRYPTION_CONTEXT = "developer_profile.github_access_token"

  CONNECT_STATUSES      = %w[pending active restricted].freeze
  VERIFICATION_STATUSES = %w[unverified identity_verified approved].freeze
  # Corrected to match new onboarding order
  ONBOARDING_STEPS      = { identity: 1, portfolio: 2, connect: 3, complete: 4 }.freeze
  AVAILABILITY_STATUSES = %w[open busy unavailable].freeze

  validates :connect_onboarding_status, inclusion: { in: CONNECT_STATUSES }
  validates :verification_status,       inclusion: { in: VERIFICATION_STATUSES }
  validates :availability,              inclusion: { in: AVAILABILITY_STATUSES }, allow_nil: true

  # Public gallery scope — only fully verified developers with a username
  scope :publicly_listed, -> {
    joins(:user)
      .where(verification_status: "approved", connect_onboarding_status: "active")
      .where.not(users: { username: nil })
      .includes(:user, user: :portfolio_submissions)
  }

  # Search by display name, tagline, or bio
  scope :search_text, ->(query) {
    return all if query.blank?

    q = "%#{sanitize_sql_like(query.strip)}%"
    where(
      "developer_profiles.display_name ILIKE :q OR developer_profiles.tagline ILIKE :q OR developer_profiles.bio ILIKE :q OR users.email ILIKE :q",
      q: q
    ).joins(:user)
  }

  # Filter by tech tag(s)
  scope :with_tags, ->(tags) {
    return all if tags.blank?

    tag_array = Array(tags).map(&:strip).reject(&:blank?)
    return all if tag_array.empty?

    # Postgres array overlap: any matching tag
    where("skill_tags && ARRAY[?]::varchar[]", tag_array)
  }

  # Filter by availability
  scope :available, -> { where(availability: "open") }

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