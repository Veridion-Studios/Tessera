module Admin
  class UsersController < BaseController
    def index
      @users = User.includes(:developer_profile, :customer_profile)
                   .order(created_at: :desc)
    end

    def show
      @user               = User.includes(:developer_profile, :customer_profile, :portfolio_submissions).find(params[:id])
      @developer_profile  = @user.developer_profile
      @customer_profile   = @user.customer_profile
      @submissions        = @user.portfolio_submissions.order(created_at: :desc)
    end
  end
end