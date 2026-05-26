module Webhooks
  class StripeController < ApplicationController
    # Webhooks are unauthenticated — skip all Devise/CSRF guards
    skip_before_action :verify_authenticity_token
    skip_before_action :authenticate_user!, raise: false

    def identity
      payload    = request.body.read
      sig_header = request.env["HTTP_STRIPE_SIGNATURE"]

      begin
        event = Stripe::Webhook.construct_event(
          payload, sig_header, ENV.fetch("STRIPE_IDENTITY_WEBHOOK_SECRET")
        )
      rescue JSON::ParserError
        return head :bad_request
      rescue Stripe::SignatureVerificationError
        return head :bad_request
      end

      case event["type"]
      when "identity.verification_session.verified",
           "identity.verification_session.requires_input"
        stripe_session = event.data.object
        IdentityVerificationService.new(stripe_session).process!
      end

      head :ok
    end
  end
end