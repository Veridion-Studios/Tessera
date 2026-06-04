module Developer
  class AgencyController < ApplicationController
    before_action :authenticate_user!
    before_action :require_developer!

    def show
      @agency = current_user.owned_agency || current_user.agency_memberships.active.first&.agency
      redirect_to new_developer_agency_path, notice: "Set up your agency first." unless @agency
    end

    def new
      @agency = current_user.owned_agency || current_user.agency_memberships.active.first&.agency
      return redirect_to developer_agency_path if @agency

      @agency = Agency.new
    end

    def create
      @agency = Agency.new(agency_params)
      @agency.owner = current_user
      if @agency.save
        @agency.memberships.create!(
          user: current_user,
          role: "owner",
          accepted_at: Time.current,
          capacity_pct: 0,
          bench_status: "unavailable"
        )
        redirect_to developer_agency_path, notice: "Agency created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      @agency = current_user.owned_agency
      return redirect_to root_path, alert: "Access denied." unless @agency

      if @agency.update(agency_params)
        redirect_to developer_agency_path, notice: "Agency updated."
      else
        render :show, status: :unprocessable_entity
      end
    end

    private

    def require_developer!
      redirect_to root_path, alert: "Access denied." unless current_user.developer?
    end

    def agency_params
      params.require(:agency).permit(
        :name, :bio, :website_url, :slug, :tagline,
        :cover_image_url, :founded_on, :visibility, :logo
      )
    end
  end
end