class QuoteMessageNotification < Noticed::Event
  deliver_by :database

  notification_methods do
    def message
      "New message on your quote: \"#{params[:title]}\""
    end

    def url
      recipient_type = params[:recipient_role]
      if recipient_type == "developer"
        Rails.application.routes.url_helpers.developer_quote_path(params[:quote_id])
      else
        Rails.application.routes.url_helpers.client_quote_path(params[:quote_id])
      end
    end
  end
end