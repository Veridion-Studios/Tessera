class ApplicationController < ActionController::Base
  if defined?(Pretender)
    impersonates :user
  end

  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_paper_trail_whodunnit
  before_action :set_sentry_user
  before_action :check_suspended!

  protected

  def user_for_paper_trail
    current_user&.id
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :password, :password_confirmation])
  end

  def set_sentry_user
    return unless current_user

    username = current_user.developer_profile&.display_name || current_user.customer_profile&.display_name || current_user.email

    Sentry.set_user(
      id:       current_user.id,
      username: username,
      email:    current_user.email,
      # Prefer to capture the real remote IP; fall back to auto inference if unavailable
      ip_address: (request&.remote_ip || "{{auto}}")
    )
  end

  def check_suspended!
    return unless current_user&.suspended_at?
    sign_out current_user
    redirect_to new_user_session_path,
      alert: "Your account has been suspended. Contact support if you believe this is an error."
  end
end