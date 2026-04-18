module Onboarding
  class PortfolioController < BaseController
    def show
      @submissions = current_user.portfolio_submissions.order(created_at: :desc)
      @submission  = PortfolioSubmission.new
      @tech_tags   = PortfolioSubmission::TECH_TAGS
    end

    def create
      @submission = current_user.portfolio_submissions.build(submission_params)

      if @submission.save
        profile.update!(onboarding_step: [profile.onboarding_step, 2].max)
        flash[:notice] = "Project submitted for review."
        redirect_to onboarding_portfolio_path
      else
        @submissions = current_user.portfolio_submissions.order(created_at: :desc)
        @tech_tags   = PortfolioSubmission::TECH_TAGS
        render :show, status: :unprocessable_entity
      end
    end

    private

    def submission_params
      params.require(:portfolio_submission).permit(:project_url, :title, :description, tech_tags: [])
    end
  end
end