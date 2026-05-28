class GalleryController < ApplicationController
  TECH_TAGS = PortfolioSubmission::TECH_TAGS

  def index
    @profiles = DeveloperProfile.publicly_listed

    # Search
    if params[:q].present?
      @profiles = @profiles.search_text(params[:q])
    end

    # Tag filter — params[:tags] is an array from checkboxes
    if params[:tags].present?
      @profiles = @profiles.with_tags(params[:tags])
    end

    # Availability filter
    if params[:availability] == "open"
      @profiles = @profiles.available
    end

    # Sort
    @profiles = case params[:sort]
    when "rate_asc"  then @profiles.order(hourly_rate: :asc)
    when "rate_desc" then @profiles.order(hourly_rate: :desc)
    when "newest"    then @profiles.order(created_at: :desc)
    else                  @profiles.order(created_at: :desc)
    end

    @tech_tags   = TECH_TAGS
    @total_count = @profiles.count
  end
end