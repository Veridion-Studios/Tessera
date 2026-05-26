module Onboarding
  class IdentityController < ApplicationController
    before_action :authenticate_user!
    before_action :require_identity_role!

    def show
        render "onboarding/identity/show"
    end

    def start
      if current_user.identity_verification_attempts >= 3
        redirect_to error_path(id: "901") and return
      end

      if current_user.identity_verified?
        redirect_to post_verified_redirect, notice: "Identity already verified." and return
      end

      # Reuse an existing incomplete session if one exists
      if current_user.stripe_identity_session_id.present? && current_user.identity_status == "pending"
        begin
          existing = Stripe::Identity::VerificationSession.retrieve(current_user.stripe_identity_session_id)
          if existing.status == "requires_input" || existing.status == "created"
            redirect_to existing.url, allow_other_host: true and return
          end
        rescue Stripe::InvalidRequestError => e
          # Session ID is stale or invalid; proceed to create a new one
          Rails.logger.warn("Stripe session retrieval failed for user #{current_user.id}: #{e.message}")
        end
      end

      begin
        stripe_session = Stripe::Identity::VerificationSession.create({
          type: "document",
          metadata: { user_id: current_user.id },
          options: { document: { allowed_types: ["driving_license", "passport", "id_card"] } },
          return_url: "#{ENV["APP_HOST"]}#{onboarding_identity_refresh_path}"
        })

        unless stripe_session&.url
          Rails.logger.error("Stripe session created but no URL returned for user #{current_user.id}")
          redirect_to error_path(id: "904") and return
        end

        current_user.update!(
          stripe_identity_session_id: stripe_session.id,
          identity_status: "pending"
        )

        # Use redirect_to with allow_other_host to ensure external redirect works
        redirect_to stripe_session.url, allow_other_host: true, status: :see_other
      rescue Stripe::StripeError => e
        Rails.logger.error("Stripe API error for user #{current_user.id}: #{e.message}")
        redirect_to error_path(id: "905") and return
      end
    end

    def refresh
      session_id = current_user.stripe_identity_session_id

      unless session_id.present?
        redirect_to error_path(id: "902") and return
      end

      begin
        stripe_session = Stripe::Identity::VerificationSession.retrieve(session_id)
        result = IdentityVerificationService.new(stripe_session).process!

        case result
        when :verified
          redirect_to post_verified_redirect, notice: "Identity verified successfully."
        when :failed
          error_code = stripe_session.last_error&.code
          error_id = IdentityVerificationService.error_id_for(error_code)
          redirect_to error_path(id: error_id)
        when :locked
          redirect_to error_path(id: "901")
        else
          # Still processing or created — ask them to wait
          redirect_to error_path(id: "903")
        end
      rescue Stripe::InvalidRequestError => e
        Rails.logger.error("Failed to retrieve Stripe session #{session_id} for user #{current_user.id}: #{e.message}")
        redirect_to error_path(id: "902")
      end
    end

    private

    def require_identity_role!
      return if current_user.developer? || current_user.customer?

      redirect_to root_path, alert: "Access denied."
    end

    def post_verified_redirect
      if current_user.developer?
        onboarding_developer_connect_path
      else
        client_dashboard_path
      end
    end
  end
end
