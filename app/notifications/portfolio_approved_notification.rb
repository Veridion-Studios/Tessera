class PortfolioApprovedNotification < Noticed::Event
  deliver_by :database

  notification_methods do
    def message
      "Your portfolio submission \"#{params[:title]}\" has been approved. You can now connect Stripe."
    end

    def url
      Rails.application.routes.url_helpers.onboarding_developer_connect_path
    end
  end
end