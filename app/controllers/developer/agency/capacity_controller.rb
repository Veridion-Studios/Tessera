module Developer
  module Agency
    class CapacityController < ApplicationController
      include Developer::AgencyScoped
      before_action :require_agency_admin!, only: [:update]

      def index
        @memberships     = @agency.memberships.active.includes(:user).order(:role, :created_at)
        @active_projects = @agency.projects.where(status: "active").includes(:developer)
        @workload        = workload_by_member
        @capacity        = @agency.team_capacity_summary
        @bench           = @agency.memberships.on_bench.includes(:user)
      end

      def update
        updates = params[:members] || {}
        updates.each do |membership_id, attrs|
          membership = @agency.memberships.find_by(id: membership_id)
          next unless membership
          membership.update!(
            capacity_pct: attrs[:capacity_pct].to_i.clamp(0, 100),
            bench_status: attrs[:bench_status].presence || membership.bench_status
          )
        end
        redirect_to developer_agency_capacity_path, notice: "Capacity updated."
      end

      private

      def workload_by_member
        @agency.projects
               .where(status: "active")
               .group(:developer_id)
               .count
      end
    end
  end
end