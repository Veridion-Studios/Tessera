class QuoteReceivedNotification < Noticed::Event
  deliver_by :database

  notification_methods do
    def message
      "New quote request: \"#{params[:title]}\" from #{params[:customer_email]}"
    end

    def url
      Rails.application.routes.url_helpers.developer_quote_path(params[:quote_id])
    end
  end
end