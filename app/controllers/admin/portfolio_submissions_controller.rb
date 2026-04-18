module Admin
  class PortfolioSubmissionsController < BaseController
    def index
      @status       = params[:status] || "pending"
      @submissions  = PortfolioSubmission.includes(:user)
                        .where(status: @status)
                        .order(created_at: :desc)
    end

    def show
      @submission = PortfolioSubmission.includes(:user).find(params[:id])
      @other_submissions = PortfolioSubmission.where(user: @submission.user)
                             .where.not(id: @submission.id)
    end

    def approve
      @submission = PortfolioSubmission.find(params[:id])
      @submission.update!(status: "approved")

      profile = @submission.user.developer_profile
      if profile
        profile.update!(
          verification_status: "approved",
          onboarding_step: [profile.onboarding_step, 2].max
        )
      end

      redirect_to admin_portfolio_submissions_path, notice: "Submission approved."
    end

    def reject
      @submission = PortfolioSubmission.find(params[:id])
      @submission.update!(
        status: "rejected",
        admin_notes: params[:admin_notes]
      )
      redirect_to admin_portfolio_submissions_path, notice: "Submission rejected."
    end
  end
end