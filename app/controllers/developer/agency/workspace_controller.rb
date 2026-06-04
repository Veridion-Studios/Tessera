module Developer
  module Agency
    class WorkspaceController < ApplicationController
      include Developer::AgencyScoped

      def index
        @memberships    = @agency.memberships.active.includes(:user).order(:role, :created_at)
        @milestones     = @agency.milestones.ordered.limit(5)
        @discussions    = @agency.discussions.recent.limit(5)
        @files          = @agency.files.recent.limit(6)
        @active_projects = @agency.projects.where(status: "active").includes(:customer).limit(5)
        @capacity       = @agency.team_capacity_summary
        @pending_proposals = @agency.proposals.where(status: "draft").count
      end
    end
  end
end