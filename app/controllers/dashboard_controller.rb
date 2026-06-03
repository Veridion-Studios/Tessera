class DashboardController < ApplicationController
  before_action :authenticate_user!

  def pick
    active_roles = current_user.role_names & %w[developer customer]
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

    # Projects
    @active_projects = Project.where(developer: current_user, status: "active")
                              .includes(:milestones, :customer).order(updated_at: :desc).limit(4)

    # Quotes
    @pending_quotes  = current_user.received_quote_requests.where(status: "submitted").count

    # Invoices
    @recent_invoices  = Invoice.where(developer: current_user)
                               .includes(:client).order(created_at: :desc).limit(4)
    @invoice_paid     = Invoice.where(developer: current_user, status: "paid").sum(:total)
    @invoice_pending  = Invoice.where(developer: current_user, status: %w[sent overdue]).sum(:total)
    @invoice_overdue  = Invoice.where(developer: current_user, status: "sent")
                               .where("due_date < ?", Date.today).sum(:total)

    # Subscriptions / MRR
    @active_subs = Subscription.where(developer: current_user, status: "active").includes(:client)
    @mrr         = @active_subs.sum { |s| s.monthly_value }

    # Agency
    @agency = current_user.owned_agency ||
              current_user.agency_memberships.active.first&.agency
    @team_count = @agency&.memberships&.active&.count || 0

    # Earnings
    @total_released = Project.where(developer: current_user).sum(:amount_released)
    @this_month     = Project.where(developer: current_user)
                             .joins(:escrow_transactions)
                             .where(escrow_transactions: { kind: "release",
                                    created_at: Time.current.beginning_of_month.. })
                             .sum("escrow_transactions.amount")
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