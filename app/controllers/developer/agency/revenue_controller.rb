module Developer
  module Agency
    class RevenueController < ApplicationController
      include Developer::AgencyScoped
      before_action :require_agency_admin!

      def index
        @memberships       = @agency.memberships.active.includes(:user).order(:role, :created_at)
        @total_pct         = @agency.total_allocated_revenue_pct
        @unallocated_pct   = [100 - @total_pct, 0].max.round(1)
        @total_revenue     = @agency.total_revenue
        @this_month        = @agency.this_month_revenue
        @splits_configured = @agency.revenue_splits_configured?
      end

      def update
        splits = params[:splits] || {}
        splits.each do |membership_id, pct|
          membership = @agency.memberships.find_by(id: membership_id)
          next unless membership
          membership.update!(revenue_share_pct: pct.to_d / 100)
        end
        redirect_to developer_agency_revenue_path, notice: "Revenue splits saved."
      end
    end
  end
end