module Onboarding
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :require_developer!

    private

    def require_developer!
      redirect_to root_path, alert: "Access denied." unless current_user.developer?
    end

    def profile
      @profile ||= current_user.developer_profile
    end
  end
end