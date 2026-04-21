class Users::RegistrationsController < Devise::RegistrationsController
  before_action :normalize_role_param, only: [:new, :create]

  protected

  def after_sign_up_path_for(resource)
    passkey_prompt_path
  end

  def build_resource(hash = {})
    super
    role = params[:role].presence || params.dig(resource_name.to_s, "role").presence
    resource.initial_role = role if role.in?(%w[customer developer])
  end

  private

  def normalize_role_param
    # Keep for view compatibility — role still passed as ?role=developer
  end

  def sign_up_params
    params.require(resource_name).permit(:email, :password, :password_confirmation)
  end
end