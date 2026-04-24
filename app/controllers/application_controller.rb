class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  # PaperTrail — track who made each change
  before_action :set_paper_trail_whodunnit

  protected

  def user_for_paper_trail
    current_user&.id
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :password, :password_confirmation])
  end
end