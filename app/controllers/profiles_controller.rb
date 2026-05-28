class ProfilesController < ApplicationController
  def show
    user = User.find_by!(username: params[:username])

    unless user.developer? && user.developer_profile&.fully_verified?
      raise ActiveRecord::RecordNotFound
    end

    @profile     = user.developer_profile
    @submissions = user.portfolio_submissions.where(status: "approved").order(created_at: :desc)
    @user        = user
  end
end