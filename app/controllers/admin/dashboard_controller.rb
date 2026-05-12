module Admin
  class DashboardController < BaseController
    def index
      developer_role = Role.find_by(name: "developer")
      customer_role  = Role.find_by(name: "customer")

      @pending_submissions = PortfolioSubmission.where(status: "pending").count
      @total_users         = User.count
      @total_developers    = developer_role ? UserRole.where(role: developer_role).count : 0
      @total_customers     = customer_role  ? UserRole.where(role: customer_role).count  : 0
      @recent_submissions  = PortfolioSubmission.includes(:user).order(created_at: :desc).limit(5)
      @recent_users        = User.order(created_at: :desc).limit(5)
    end
  end
end