module Developer
  class EarningsController < ApplicationController
    before_action :authenticate_user!
    before_action :require_developer!

    def index
      @profile   = current_user.developer_profile
      @projects  = Project.where(developer: current_user).includes(:milestones)

      @total_released  = @projects.sum(:amount_released)
      @total_pending   = @projects.where(status: "active").joins(:milestones)
                                  .where(project_milestones: { status: "approved" })
                                  .sum("project_milestones.amount")
      @total_in_escrow = @projects.where(status: "active").sum(:amount_held)

      @recent_transactions = EscrowTransaction.joins(:project)
                                              .where(projects: { developer: current_user }, kind: "release")
                                              .includes(:project, :milestone)
                                              .order(created_at: :desc)
                                              .limit(20)

      # Live Stripe Connect balance — rescue gracefully if not connected
      @stripe_balance = if @profile.stripe_connect_id.present?
        begin
          Stripe::Balance.retrieve({ stripe_account: @profile.stripe_connect_id })
        rescue Stripe::StripeError => e
          Rails.logger.warn("Stripe balance fetch failed: #{e.message}")
          nil
        end
      end
    end

    private

    def require_developer!
      redirect_to root_path, alert: "Access denied." unless current_user.developer?
    end
  end
end