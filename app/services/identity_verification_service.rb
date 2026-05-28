# Handles all Stripe Identity verification outcome logic.
# Called by both the webhook (async) and the refresh action (manual poll).
class IdentityVerificationService
  ERRORS_PATH = Rails.root.join("config/errors.json").freeze

  def initialize(stripe_session)
    @stripe_session = stripe_session
  end

  # Returns :verified, :failed, :locked, :canceled, or :pending
  def process!
    user = User.find_by(stripe_identity_session_id: @stripe_session.id)
    return :no_user unless user

    case @stripe_session.status
    when "verified"
      apply_verified!(user)
      :verified
    when "requires_input"
      apply_failed!(user)
    when "canceled"
      :canceled
    else
      :pending
    end
  end

  def self.error_catalog
    @error_catalog ||= JSON.parse(File.read(ERRORS_PATH))
  end

  # Returns the errors.json ID for a given Stripe error code, falling back to "900"
  def self.error_id_for(code)
    return "900" if code.blank?
    error_catalog.find { |_, info| info["error"] == code.to_s }&.first || "900"
  end

  # Returns the human-readable text for a given Stripe error code
  def self.friendly_error(code)
    return error_catalog["900"]["text"] if code.blank?
    entry = error_catalog.find { |_, info| info["error"] == code.to_s }
    entry ? entry[1]["text"] : error_catalog["900"]["text"]
  end

  private

  def apply_verified!(user)
    user.update!(identity_status: "verified", identity_verification_attempts: 0)
    IdentityVerifiedNotification.with(user: user).deliver(user)

    if user.developer? && user.developer_profile
      user.developer_profile.update!(
        verification_status: "identity_verified",
        onboarding_step: [user.developer_profile.onboarding_step, 2].max
      )
    end

    if user.customer? && user.customer_profile
      user.customer_profile.update!(identity_status: "verified")
    end
  end

  def apply_failed!(user)
    user.increment!(:identity_verification_attempts)

    if user.identity_verification_attempts >= 3
      user.update!(identity_status: "locked")
      IdentityVerificationLockedNotification.with(user: user).deliver(user)
      return :locked
    end

    user.update!(identity_status: "requires_input")
    IdentityVerificationFailedNotification.with(
      user: user,
      error_code: @stripe_session.last_error&.code
    ).deliver(user)
    :failed
  end
end