module Admin
  class DashboardController < BaseController
    def index
      @pending_submissions  = PortfolioSubmission.where(status: "pending").count
      @total_users          = User.count
      @total_developers     = User.where("'developer' = ANY(roles)").count
      @total_customers      = User.where("'customer' = ANY(roles)").count
      @recent_submissions   = PortfolioSubmission.includes(:user).order(created_at: :desc).limit(5)
      @recent_users         = User.order(created_at: :desc).limit(5)
    end
  end
end