module Onboarding
  class IdentityController < ApplicationController
    before_action :authenticate_user!
    before_action :require_identity_role!
    before_action :redirect_if_locked, only: [:show, :start]

    def show
      render "onboarding/identity/show"
    end

    def start
      if current_user.identity_verified?
        redirect_to post_verified_redirect, notice: "Identity already verified." and return
      end

      # Reuse an existing session that is still actionable
      if current_user.stripe_identity_session_id.present?
        begin
          existing = Stripe::Identity::VerificationSession.retrieve(current_user.stripe_identity_session_id)
          unless %w[verified canceled].include?(existing.status)
            redirect_to existing.url, allow_other_host: true and return
          end
        rescue Stripe::InvalidRequestError => e
          Rails.logger.warn("Stale Stripe session for user #{current_user.id}: #{e.message}")
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

        redirect_to stripe_session.url, allow_other_host: true, status: :see_other
      rescue Stripe::StripeError => e
        Rails.logger.error("Stripe API error for user #{current_user.id}: #{e.message}")
        redirect_to error_path(id: "905")
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
          error_id = IdentityVerificationService.error_id_for(stripe_session.last_error&.code)
          redirect_to error_path(id: error_id)
        when :locked
          redirect_to error_path(id: "901")
        when :canceled
          # User backed out of Stripe's flow — send them back to try again
          redirect_to onboarding_identity_path, alert: "Verification was canceled. You can start again when you're ready."
        else
          # "processing" / unknown — Stripe hasn't resolved it yet
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

    def redirect_if_locked
      redirect_to error_path(id: "901") if current_user.identity_status == "locked" ||
                                           current_user.identity_verification_attempts >= 3
    end

    def post_verified_redirect
      current_user.developer? ? onboarding_developer_portfolio_path : client_dashboard_path
    end
  end
end