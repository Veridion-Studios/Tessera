class IdentityVerifiedNotification < Noticed::Event
  deliver_by :database

  notification_methods do
    def message
      "Your identity has been verified. You can now continue onboarding."
    end

    def url
      Rails.application.routes.url_helpers.onboarding_developer_portfolio_path
    end
  end
end