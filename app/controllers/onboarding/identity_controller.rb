module Onboarding
  class IdentityController < BaseController
    def show
    end

    def start
      session = Stripe::Identity::VerificationSession.create({
        type: "document",
        metadata: { user_id: current_user.id },
        options: { document: { allowed_types: ["driving_license", "passport", "id_card"] } },
        return_url: "#{ENV["APP_HOST"]}#{onboarding_identity_refresh_path}"
      })

      current_user.update!(
        stripe_identity_session_id: session.id,
        identity_status: "pending"
      )

      redirect_to session.url, allow_other_host: true
    end

    def refresh
      session_id = current_user.stripe_identity_session_id

      if session_id.present?
        session = Stripe::Identity::VerificationSession.retrieve(session_id)

        if session.status == "verified"
          current_user.update!(identity_status: "verified")
          profile.update!(
            verification_status: "identity_verified",
            onboarding_step: [profile.onboarding_step, 3].max
          )
          flash[:notice] = "Identity verified successfully."
          redirect_to onboarding_connect_path
        else
          flash[:alert] = "Verification incomplete. Please try again."
          redirect_to onboarding_identity_path
        end
      else
        redirect_to onboarding_identity_path
      end
    end
  end
end