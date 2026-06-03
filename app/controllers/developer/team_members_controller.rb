module Developer
  class TeamMembersController < ApplicationController
    before_action :authenticate_user!
    before_action :require_agency_admin!

    def index
      @agency      = current_agency
      @memberships = @agency.memberships.includes(:user).order(created_at: :asc)
      @workload    = workload_by_member
    end

    def new
      @membership = AgencyMembership.new
    end

    def create
      user = User.find_by(email: params[:email].to_s.strip.downcase)
      return redirect_to developer_team_members_path, alert: "No user found with that email." unless user

      membership = current_agency.memberships.find_or_initialize_by(user: user)
      membership.assign_attributes(
        role:            params[:role].presence || "member",
        title:           params[:title],
        revenue_share_pct: params[:revenue_share_pct].to_d / 100,
        invited_at:      Time.current
      )

      if membership.save
        redirect_to developer_team_members_path, notice: "#{user.email} invited."
      else
        redirect_to developer_team_members_path, alert: "Could not add team member."
      end
    end

    def update
      membership = current_agency.memberships.find(params[:id])
      membership.update!(
        role:              params[:role].presence || membership.role,
        title:             params[:title].presence || membership.title,
        revenue_share_pct: params[:revenue_share_pct].to_d / 100,
        internal_notes:    params[:internal_notes]
      )
      redirect_to developer_team_members_path, notice: "Member updated."
    end

    def destroy
      membership = current_agency.memberships.find(params[:id])
      return redirect_to developer_team_members_path, alert: "Cannot remove the agency owner." if membership.role == "owner"
      membership.update!(deactivated_at: Time.current)
      redirect_to developer_team_members_path, notice: "Member removed."
    end

    private

    def current_agency
      @current_agency ||= current_user.owned_agency ||
                          current_user.agency_memberships.active.where(role: %w[owner admin]).first&.agency
    end

    def require_agency_admin!
      redirect_to root_path, alert: "Access denied." unless current_agency
    end

    def workload_by_member
      # Active projects per member (projects where their user is developer_id)
      current_agency.projects
                    .where(status: "active")
                    .group(:developer_id)
                    .count
    end
  end
end