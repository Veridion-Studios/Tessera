class Users::SessionsController < Devise::SessionsController
  protected

  def after_sign_in_path_for(resource)
    if resource.developer? && !resource.developer_profile.fully_verified?
      step = resource.developer_profile.onboarding_step
      case step
      when 1 then onboarding_portfolio_path
      when 2 then onboarding_identity_path
      when 3 then onboarding_connect_path
      else dashboard_path
      end
    else
      dashboard_path
    end
  end
end