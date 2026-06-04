module Developer
  module AgencyScoped
    extend ActiveSupport::Concern

    included do
      before_action :authenticate_user!
      before_action :require_developer!
      before_action :set_agency
      before_action :require_agency!
    end

    private

    def set_agency
      @agency = current_user.owned_agency ||
                current_user.agency_memberships.active.first&.agency
    end

    def require_agency!
      redirect_to new_developer_agency_path, alert: "Set up your agency first." unless @agency
    end

    def require_agency_admin!
      unless @agency.admin?(current_user)
        redirect_to developer_agency_agency_workspace_path, alert: "Access denied."
      end
    end

    def require_developer!
      redirect_to root_path, alert: "Access denied." unless current_user.developer?
    end
  end
end