class SupportReplyNotification < Noticed::Event
  # DISABLED: Support notifications
  # deliver_by :database

  notification_methods do
    def message
      "New reply on your support ticket: \"#{params[:subject]}\""
    end

    def url
      Rails.application.routes.url_helpers.support_conversation_path(params[:conversation_id])
    end
  end
end