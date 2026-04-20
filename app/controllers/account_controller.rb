class AccountController < ApplicationController
  before_action :authenticate_user!

  def settings
    @passkeys = current_user.passkeys.order(created_at: :desc)
  end

  def update_email
    if current_user.valid_password?(params[:current_password])
      if current_user.update(email: params[:email])
        bypass_sign_in(current_user)
        redirect_to account_settings_path, notice: "Email updated."
      else
        flash[:alert] = current_user.errors.full_messages.to_sentence
        redirect_to account_settings_path
      end
    else
      flash[:alert] = "Current password is incorrect."
      redirect_to account_settings_path
    end
  end

  def update_password
    if current_user.update_with_password(
      password:              params[:password],
      password_confirmation: params[:password_confirmation],
      current_password:      params[:current_password]
    )
      bypass_sign_in(current_user)
      redirect_to account_settings_path, notice: "Password updated."
    else
      flash[:alert] = current_user.errors.full_messages.to_sentence
      redirect_to account_settings_path
    end
  end

  def destroy
    if current_user.valid_password?(params[:password])
      current_user.destroy!
      redirect_to root_path, notice: "Your account has been deleted."
    else
      flash[:alert] = "Incorrect password. Account not deleted."
      redirect_to account_settings_path
    end
  end

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