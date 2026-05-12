class NotificationsController < ApplicationController
  def index
    @notifications = current_user.notifications
                       .includes(:event)
                       .order(created_at: :desc)
                       .limit(50)
    current_user.notifications.unread.update_all(read_at: Time.current)
  end

  def mark_read
    notification = current_user.notifications.find(params[:id])
    notification.mark_as_read!
    head :ok
  end

  def mark_all
    current_user.notifications.unread.update_all(read_at: Time.current)
    redirect_back fallback_location: notifications_path
  end
end