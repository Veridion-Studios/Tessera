module Admin
  class ProjectsController < BaseController
    def index
      @projects = Project.includes(:developer, :customer, :milestones)
                         .order(created_at: :desc)

      @projects = @projects.where(status: params[:status]) if params[:status].present?
      @projects = @projects.joins(:developer).where("users.email ILIKE ?", "%#{params[:q]}%") if params[:q].present?

      @status_counts = Project::STATUSES.index_with { |s| Project.where(status: s).count }
    end

    def show
      @project    = Project.includes(:developer, :customer, :milestones, :devlog_entries, :escrow_transactions).find(params[:id])
      @milestones = @project.milestones.order(:position)
      @devlogs    = @project.devlog_entries.includes(:author, :milestone).order(created_at: :desc)
      @escrow_txs = @project.escrow_transactions.includes(:milestone).order(created_at: :desc)
    end
  end
end