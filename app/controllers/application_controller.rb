class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_paper_trail_whodunnit
  before_action :set_sentry_user

  protected

  def user_for_paper_trail
    current_user&.id
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :password, :password_confirmation])
  end

  def set_sentry_user
    return unless current_user

    Sentry.set_user(
      id:    current_user.id,
      email: current_user.email
    )
  end
end