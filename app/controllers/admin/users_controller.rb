module Admin
  class UsersController < BaseController
    def index
      @users = User.includes(:roles, :developer_profile, :customer_profile)
                   .order(created_at: :desc)

      if params[:role].present?
        @users = @users.joins(:roles).where(roles: { name: params[:role] })
      end
      if params[:status].present?
        @users = @users.where(identity_status: params[:status])
      end
      if params[:q].present?
        @users = @users.where("email ILIKE ?", "%#{params[:q]}%")
      end
    end

    def show
      @user              = User.includes(:roles, :developer_profile, :customer_profile, :portfolio_submissions).find(params[:id])
      @developer_profile = @user.developer_profile
      @customer_profile  = @user.customer_profile
      @submissions       = @user.portfolio_submissions.order(created_at: :desc)
      @notifications     = @user.notifications.order(created_at: :desc).limit(20)
    end

    def update
      @user = User.find(params[:id])

      if params[:admin_notes]
        @user.update!(admin_notes: params[:admin_notes])
      end

      redirect_to admin_user_path(@user), notice: "User updated."
    end

    def revoke_identity
      @user = User.find(params[:id])
      @user.update!(identity_status: "unverified", identity_revoked_at: Time.current)
      @user.developer_profile&.update!(verification_status: "unverified")
      @user.customer_profile&.update!(identity_status: "unverified")
      redirect_to admin_user_path(@user), notice: "Identity revoked."
    end

    def verify_identity
      @user = User.find(params[:id])
      @user.update!(identity_status: "verified", identity_revoked_at: nil)
      @user.developer_profile&.update!(verification_status: "identity_verified")
      @user.customer_profile&.update!(identity_status: "verified")
      redirect_to admin_user_path(@user), notice: "Identity manually verified."
    end

    def suspend
      @user = User.find(params[:id])
      @user.update!(suspended_at: Time.current, suspension_reason: params[:reason])
      redirect_to admin_user_path(@user), notice: "User suspended."
    end

    def unsuspend
      @user = User.find(params[:id])
      @user.update!(suspended_at: nil, suspension_reason: nil)
      redirect_to admin_user_path(@user), notice: "User reinstated."
    end

    def grant_admin
      @user = User.find(params[:id])
      @user.add_role!("admin")
      redirect_to admin_user_path(@user), notice: "Admin role granted."
    end

    def revoke_admin
      @user = User.find(params[:id])
      if @user == current_user
        redirect_to admin_user_path(@user), alert: "You cannot revoke your own admin role."
      else
        role = Role.find_by(name: "admin")
        @user.user_roles.find_by(role: role)&.destroy
        redirect_to admin_user_path(@user), notice: "Admin role revoked."
      end
    end
  end
end