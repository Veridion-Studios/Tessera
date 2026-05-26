module Onboarding
  module Developer
    class IdentityController < BaseController
      def show
      end

      def start
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
            return_url: "#{ENV["APP_HOST"]}#{onboarding_developer_identity_refresh_path}"
          })

          unless stripe_session&.url
            Rails.logger.error("Stripe session created but no URL returned for user #{current_user.id}")
            redirect_to onboarding_developer_identity_path, alert: "Failed to initialize verification session. Please try again." and return
          end

          current_user.update!(
            stripe_identity_session_id: stripe_session.id,
            identity_status: "pending"
          )

          # Use redirect_to with allow_other_host to ensure external redirect works
          redirect_to stripe_session.url, allow_other_host: true, status: :see_other
        rescue Stripe::StripeError => e
          Rails.logger.error("Stripe API error for user #{current_user.id}: #{e.message}")
          redirect_to onboarding_developer_identity_path, alert: "Unable to start verification. Please try again or contact support." and return
        end
      end

      def refresh
        session_id = current_user.stripe_identity_session_id

        unless session_id.present?
          redirect_to onboarding_developer_identity_path and return
        end

        begin
          stripe_session = Stripe::Identity::VerificationSession.retrieve(session_id)
          result = IdentityVerificationService.new(stripe_session).process!

          case result
          when :verified
            flash[:notice] = "Identity verified successfully."
            redirect_to onboarding_developer_connect_path
          when :failed
            error_code = stripe_session.last_error&.code
            flash[:alert] = IdentityVerificationService.friendly_error(error_code)
            redirect_to onboarding_developer_identity_path
          else
            # Still processing or created — ask them to wait
            flash[:alert] = "Verification is still being processed. Please wait a moment and try again."
            redirect_to onboarding_developer_identity_path
          end
        rescue Stripe::InvalidRequestError => e
          Rails.logger.error("Failed to retrieve Stripe session #{session_id} for user #{current_user.id}: #{e.message}")
          flash[:alert] = "Verification session not found or has expired. Please start over."
          redirect_to onboarding_developer_identity_path
        end
      end
    end
  end
end