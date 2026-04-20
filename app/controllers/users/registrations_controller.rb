class Users::RegistrationsController < Devise::RegistrationsController
  before_action :normalize_role_param, only: [:new, :create]

  protected

  def after_sign_up_path_for(resource)
    passkey_prompt_path
  end

  private

  def normalize_role_param
    role = params[:role].to_s
    return unless %w[customer developer].include?(role)

    params[resource_name] ||= ActionController::Parameters.new
    params[resource_name][:roles] = [role] if params[resource_name][:roles].blank?
  end
end