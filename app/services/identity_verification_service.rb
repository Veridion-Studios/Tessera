# Handles all Stripe Identity verification outcome logic.
# Called by both the webhook (async) and the refresh action (manual poll).
class IdentityVerificationService
  FRIENDLY_ERRORS = {
    "consent_declined"                    => "You declined to be verified. Verification is required to use Tessera.",
    "under_supported_age"                 => "Stripe does not support verification for users under the age of majority.",
    "country_not_supported"               => "Your country is not currently supported for identity verification.",
    "document_expired"                    => "The document you provided has expired. Please use a valid, current document.",
    "document_unverified_other"           => "We couldn't verify your document. Please ensure it's clear and try again.",
    "document_type_not_supported"         => "That document type isn't accepted. Please use a passport, driver's license, or national ID card.",
    "selfie_document_missing_photo"       => "Your document didn't contain a photo. Please use a photo ID.",
    "selfie_face_mismatch"                => "The selfie didn't match the face on your document. Please try again in good lighting.",
    "selfie_unverified_other"             => "We couldn't verify your selfie. Please try again in good lighting.",
    "selfie_manipulated"                  => "The selfie image appeared to be manipulated and cannot be accepted.",
    "id_number_unverified_other"          => "We couldn't verify your ID number.",
    "id_number_insufficient_document_data"=> "Your document didn't contain enough data to complete verification.",
    "id_number_mismatch"                  => "The information provided didn't match our records.",
    "address_mismatch"                    => "The address provided didn't match our records.",
  }.freeze

  def initialize(stripe_session)
    @stripe_session = stripe_session
  end

  # Returns :verified, :failed, or :pending
  def process!
    user = User.find_by(stripe_identity_session_id: @stripe_session.id)
    return :no_user unless user

    case @stripe_session.status
    when "verified"
      apply_verified!(user)
      :verified
    when "requires_input"
      apply_failed!(user)
      :failed
    else
      :pending
    end
  end

  # Human-readable failure reason from last_error.code
  def self.friendly_error(code)
    FRIENDLY_ERRORS.fetch(code.to_s, "Verification failed. Please try again or contact support.")
  end

  private

  def apply_verified!(user)
    user.update!(identity_status: "verified")

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
    user.update!(identity_status: "requires_input")
  end
end