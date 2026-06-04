module Developer
  module Agency
    class MilestonesController < ApplicationController
      include Developer::AgencyScoped
      before_action :require_agency_admin!, only: [:create, :update, :destroy]

      def index
        @milestones = @agency.milestones.ordered
      end

      def create
        @milestone = @agency.milestones.build(milestone_params)
        @milestone.position = (@agency.milestones.maximum(:position) || 0) + 1
        if @milestone.save
          redirect_to developer_agency_milestones_path, notice: "Milestone added."
        else
          redirect_to developer_agency_milestones_path, alert: "Could not save milestone."
        end
      end

      def update
        @milestone = @agency.milestones.find(params[:id])
        if @milestone.update(milestone_params)
          redirect_to developer_agency_milestones_path, notice: "Milestone updated."
        else
          redirect_to developer_agency_milestones_path, alert: "Could not update milestone."
        end
      end

      def destroy
        @agency.milestones.find(params[:id]).destroy
        redirect_to developer_agency_milestones_path, notice: "Milestone removed."
      end

      private

      def milestone_params
        params.require(:agency_milestone).permit(:title, :description, :due_date, :status, :project_id)
      end
    end
  end
end