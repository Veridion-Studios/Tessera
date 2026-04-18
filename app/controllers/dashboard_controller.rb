class DashboardController < ApplicationController
  before_action :authenticate_user!

  def pick
    # If they only have one role, skip the picker and redirect directly
    active_roles = current_user.roles & %w[developer customer]
    if active_roles.length == 1
      redirect_to active_roles.first == "developer" ? developer_dashboard_path : client_dashboard_path
    end
  end

  def switch
    role = params[:role]
    unless current_user.has_role?(role)
      redirect_to pick_dashboard_path, alert: "You don't have that role."
      return
    end
    session[:active_role] = role
    redirect_to role == "developer" ? developer_dashboard_path : client_dashboard_path
  end

  def developer
    unless current_user.developer?
      redirect_to pick_dashboard_path, alert: "Access denied."
      return
    end
    session[:active_role] = "developer"
    @profile     = current_user.developer_profile
    @submissions = current_user.portfolio_submissions.order(created_at: :desc)
  end

  def client
    unless current_user.customer?
      redirect_to pick_dashboard_path, alert: "Access denied."
      return
    end
    session[:active_role] = "customer"
    @profile = current_user.customer_profile
  end
end