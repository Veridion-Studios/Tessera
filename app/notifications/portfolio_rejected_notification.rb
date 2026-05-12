class PortfolioRejectedNotification < Noticed::Event
  deliver_by :database

  notification_methods do
    def message
      "Your portfolio submission \"#{params[:title]}\" was not approved. #{params[:reason].presence || 'Please review and resubmit.'}"
    end

    def url
      Rails.application.routes.url_helpers.onboarding_developer_portfolio_path
    end
  end
end