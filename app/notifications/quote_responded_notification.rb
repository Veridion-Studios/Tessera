class QuoteRespondedNotification < Noticed::Event
  deliver_by :database

  notification_methods do
    def message
      action = params[:action]  # "accepted", "declined", "countered"
      "#{params[:developer_name]} #{action} your quote for \"#{params[:title]}\""
    end

    def url
      Rails.application.routes.url_helpers.client_quote_path(params[:quote_id])
    end
  end
end