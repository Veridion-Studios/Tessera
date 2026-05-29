module Admin
  class EscrowController < BaseController
    def index
      @total_held     = Project.sum(:amount_held)
      @total_released = Project.sum(:amount_released)
      @funded_projects = Project.where.not(escrow_status: %w[unfunded released refunded])
                                .includes(:developer, :customer, :milestones)
                                .order(created_at: :desc)
      @recent_transactions = EscrowTransaction.includes(:project, :milestone)
                                              .order(created_at: :desc)
                                              .limit(50)
    end
  end
end