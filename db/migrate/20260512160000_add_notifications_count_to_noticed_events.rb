class AddNotificationsCountToNoticedEvents < ActiveRecord::Migration[8.1]
  def change
    unless column_exists?(:noticed_events, :notifications_count)
      add_column :noticed_events, :notifications_count, :integer, default: 0, null: false
    end
  end
end
