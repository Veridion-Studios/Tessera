module Client
  class IdentityController < ApplicationController
    before_action :authenticate_user!
    before_action :require_customer!

    def show
    end

    def start
      # If they already have a Stripe session from developer onboarding, reuse it
      if current_user.stripe_identity_session_id.present? && current_user.identity_verified?
        apply_verification_to_customer_profile!
        redirect_to client_dashboard_path, notice: "Identity already verified."
        return
      end

      stripe_session = Stripe::Identity::VerificationSession.create({
        type: "document",
        metadata: { user_id: current_user.id },
        options: { document: { allowed_types: ["driving_license", "passport", "id_card"] } },
        return_url: "#{ENV["APP_HOST"]}#{client_identity_refresh_path}"
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
          apply_verification_to_customer_profile!

          # Also apply to developer profile if they have one (shared verification)
          if current_user.developer? && current_user.developer_profile.verification_status == "unverified"
            current_user.developer_profile.update!(verification_status: "identity_verified")
          end

          flash[:notice] = "Identity verified successfully."
          redirect_to client_dashboard_path
        else
          flash[:alert] = "Verification incomplete. Please try again."
          redirect_to client_identity_path
        end
      else
        redirect_to client_identity_path
      end
    end

    private

    def require_customer!
      redirect_to root_path, alert: "Access denied." unless current_user.customer?
    end

    def apply_verification_to_customer_profile!
      current_user.customer_profile.update!(identity_status: "verified")
    end
  end
end