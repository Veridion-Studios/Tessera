module Developer
  class ProjectsController < ApplicationController
    before_action :authenticate_user!
    before_action :require_developer!

    def index
      @active    = Project.where(developer: current_user, status: "active").includes(:customer, :milestones).order(created_at: :desc)
      @paused    = Project.where(developer: current_user, status: "paused").includes(:customer, :milestones).order(created_at: :desc)
      @completed = Project.where(developer: current_user, status: "completed").includes(:customer).order(completed_at: :desc).limit(10)
    end

    def show
      @project    = Project.where(developer: current_user).find(params[:id])
      @milestones = @project.milestones.order(:position)
      @devlogs    = @project.devlog_entries.includes(:author, :milestone).limit(20)
    end

    private

    def require_developer!
      redirect_to root_path, alert: "Access denied." unless current_user.developer?
    end
  end
end