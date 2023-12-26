class NotificationsController < ApplicationController
  def mark_as_read
    @notification = Notification.find(params[:id])
    @notification.update(read_at: DateTime.now)
    redirect_to @notification.url
  end
  def mark_all_as_read
    current_user.notifications.update_all(read_at: Time.now)
    redirect_back(fallback_location: request.referer)
  end

  def index
    @notifications = Notification.where(recipient_id: current_user.id).order(created_at: :desc)
  end


end
