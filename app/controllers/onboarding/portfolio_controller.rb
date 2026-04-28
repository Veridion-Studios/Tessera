module Onboarding
  class PortfolioController < BaseController
    require "net/http"
    require "json"

    def show
      @submissions = current_user.portfolio_submissions.order(created_at: :desc)
      @submission  = PortfolioSubmission.new
      @tech_tags   = PortfolioSubmission::TECH_TAGS
    end

    def github_repos
      query = params[:q].to_s.strip.downcase
      return render json: [] if query.blank?

      token = profile.github_access_token
      return render json: [] if token.blank?

      repos = fetch_github_repos(token)
      results = repos
        .select { |repo| repo["full_name"].to_s.downcase.include?(query) }
        .first(20)
        .map do |repo|
          {
            full_name: repo["full_name"],
            html_url: repo["html_url"],
            private: repo["private"]
          }
        end

      render json: results
    rescue StandardError
      render json: []
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
      params.require(:portfolio_submission).permit(:github_repo_url, :project_demo_url, :title, :description, tech_tags: [])
    end

    def fetch_github_repos(token)
      uri = URI("https://api.github.com/user/repos")
      uri.query = URI.encode_www_form(
        per_page: 100,
        sort: "updated",
        affiliation: "owner,collaborator,organization_member",
        visibility: "all"
      )

      request = Net::HTTP::Get.new(uri)
      request["Authorization"] = "Bearer #{token}"
      request["Accept"] = "application/vnd.github+json"
      request["X-GitHub-Api-Version"] = "2022-11-28"
      request["User-Agent"] = "Tessera-Portfolio-Setup"

      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      return [] unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.body)
    end
  end
end