class AccountController < ApplicationController
  before_action :authenticate_user!

  def confirm_role
    @role = params[:role]
    unless @role.in?(%w[developer customer])
      redirect_to pick_dashboard_path, alert: "Unknown role."
    end
  end

  def add_role
    role = params[:role]

    case role
    when "developer"
      unless current_user.can_add_developer_role?
        redirect_to pick_dashboard_path,
          alert: "Complete client verification before adding a developer profile."
        return
      end
      current_user.update!(roles: current_user.roles | ["developer"])
      current_user.create_developer_profile!
      redirect_to onboarding_portfolio_path,
        notice: "Developer profile created. Complete onboarding to go live."

    when "customer"
      unless current_user.can_add_customer_role?
        redirect_to pick_dashboard_path, alert: "Unable to add client role."
        return
      end
      current_user.update!(roles: current_user.roles | ["customer"])
      current_user.create_customer_profile!
      redirect_to client_dashboard_path, notice: "Client profile added."

    else
      redirect_to pick_dashboard_path, alert: "Unknown role."
    end
  end
end