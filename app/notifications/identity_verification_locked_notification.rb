class IdentityVerificationLockedNotification < Noticed::Event
  deliver_by :database

  notification_methods do
    def message
      "You have exceeded the maximum number of identity verification attempts. Please contact support to resolve this issue."
    end

    def url
      # This could point to a contact or support page.
      # For now, we'll point to the main dashboard.
      Rails.application.routes.url_helpers.dashboard_path
    end
  end
end
