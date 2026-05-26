class IdentityVerificationFailedNotification < Noticed::Event
  deliver_by :database

  notification_methods do
    def message
      reason = IdentityVerificationService.friendly_error(params[:error_code])
      "Identity verification failed: #{reason}"
    end

    def url
      # The URL could point to a page where the user can retry verification.
      # For now, it will point to the identity verification page.
      Rails.application.routes.url_helpers.new_identity_verification_path
    end
  end
end
