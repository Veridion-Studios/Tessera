class DashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    if current_user.developer?
      @profile = current_user.developer_profile
      @submissions = current_user.portfolio_submissions.order(created_at: :desc)
    elsif current_user.customer?
      @profile = current_user.customer_profile
    end
  end
end