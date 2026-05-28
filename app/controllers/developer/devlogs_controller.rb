module Developer
  class DevlogsController < ApplicationController
    before_action :authenticate_user!
    before_action :require_developer!

    def index
      project_ids = Project.where(developer: current_user, status: %w[active paused]).pluck(:id)
      @projects   = Project.where(id: project_ids).includes(:milestones, :customer).order(updated_at: :desc)
      @recent_entries = DevlogEntry.where(project_id: project_ids)
                                   .includes(:project, :milestone)
                                   .order(created_at: :desc)
                                   .limit(30)
      @selected_project = params[:project_id] ? Project.where(developer: current_user).find_by(id: params[:project_id]) : @projects.first
      if @selected_project
        @entries    = @selected_project.devlog_entries.includes(:milestone).order(created_at: :desc)
        @milestones = @selected_project.milestones.order(:position)
        @new_entry  = DevlogEntry.new
      end
    end

    def create
      @project = Project.where(developer: current_user).find(params[:project_id])
      @entry   = @project.devlog_entries.build(entry_params.merge(author: current_user))
      if @entry.save
        redirect_to developer_devlogs_path(project_id: @project.id), notice: "Entry added."
      else
        redirect_to developer_devlogs_path(project_id: @project.id), alert: @entry.errors.full_messages.first
      end
    end

    private

    def require_developer!
      redirect_to root_path, alert: "Access denied." unless current_user.developer?
    end

    def entry_params
      params.require(:devlog_entry).permit(:body, :kind, :commit_sha, :commit_url, :milestone_id, :visible_to_customer)
    end
  end
end