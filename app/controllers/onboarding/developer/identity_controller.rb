module Onboarding
  module Developer
    class IdentityController < BaseController
      def show
      end

      def start
        stripe_session = Stripe::Identity::VerificationSession.create({
          type: "document",
          metadata: { user_id: current_user.id },
          options: { document: { allowed_types: ["driving_license", "passport", "id_card"] } },
          return_url: "#{ENV["APP_HOST"]}#{onboarding_developer_identity_refresh_path}"
        })

        current_user.update!(
          stripe_identity_session_id: stripe_session.id,
          identity_status: "pending"
        )

        redirect_to stripe_session.url, allow_other_host: true
      end

      def refresh
        session_id = current_user.stripe_identity_session_id

        if session_id.present?
          stripe_session = Stripe::Identity::VerificationSession.retrieve(session_id)

          if stripe_session.status == "verified"
            current_user.update!(identity_status: "verified")
            if current_user.customer? && current_user.customer_profile.identity_status == "unverified"
              current_user.customer_profile.update!(identity_status: "verified")
            end
            profile.update!(
              verification_status: "identity_verified",
              onboarding_step: [profile.onboarding_step, 2].max
            )
            flash[:notice] = "Identity verified successfully."
            redirect_to onboarding_developer_portfolio_path
          else
            flash[:alert] = "Verification incomplete. Please try again."
            redirect_to onboarding_developer_identity_path
          end
        else
          redirect_to onboarding_developer_identity_path
        end
      end
    end
  end
end