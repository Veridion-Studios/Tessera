class OauthController < ApplicationController
  before_action :authenticate_user!

  def github
    auth = request.env["omniauth.auth"]

    if current_user.developer?
      profile = current_user.developer_profile
      profile.update!(
        github_uid: auth.uid,
        github_username: auth.info.nickname,
        github_url: auth.info.urls&.dig(:GitHub) || "https://github.com/#{auth.info.nickname}",
        github_connected_at: Time.current
      )
      flash[:notice] = "GitHub connected successfully."
    end

    redirect_to onboarding_portfolio_path
  end
end