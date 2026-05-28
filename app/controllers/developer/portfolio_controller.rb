module Developer
  class PortfolioController < ApplicationController
    before_action :authenticate_user!
    before_action :require_developer!

    def index
      @profile     = current_user.developer_profile
      @tessera_submissions = current_user.portfolio_submissions.order(created_at: :desc)
      @completed_projects  = Project.where(developer: current_user, status: "completed")
                                    .includes(:customer).order(completed_at: :desc)
      @tech_tags = PortfolioSubmission::TECH_TAGS
    end

    def update_profile
      @profile = current_user.developer_profile
      if @profile.update(profile_params)
        redirect_to developer_portfolio_path, notice: "Profile updated."
      else
        @tessera_submissions = current_user.portfolio_submissions.order(created_at: :desc)
        @completed_projects  = Project.where(developer: current_user, status: "completed")
        @tech_tags = PortfolioSubmission::TECH_TAGS
        render :index, status: :unprocessable_entity
      end
    end

    private

    def require_developer!
      redirect_to root_path, alert: "Access denied." unless current_user.developer?
    end

    def profile_params
      params.require(:developer_profile).permit(
        :display_name, :tagline, :bio, :location,
        :hourly_rate, :availability, :website_url, :twitter_handle,
        skill_tags: []
      )
    end
  end
end