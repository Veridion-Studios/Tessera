module Developer
  class CrmController < ApplicationController
    before_action :authenticate_user!
    before_action :require_developer!

    def index
      # All clients this developer has ever worked with or quoted
      quote_customer_ids = current_user.received_quote_requests.pluck(:customer_id)
      project_customer_ids = Project.where(developer: current_user).pluck(:customer_id)
      @all_customer_ids = (quote_customer_ids + project_customer_ids).uniq

      @contacts = User.where(id: @all_customer_ids)
                      .includes(:customer_profile, :sent_quote_requests)
                      .order(created_at: :desc)

      @contacts = @contacts.where("email ILIKE ?", "%#{params[:q]}%") if params[:q].present?

      # Build contact cards with relationship data
      @contact_data = @contacts.map do |contact|
        quotes    = current_user.received_quote_requests.where(customer: contact)
        projects  = Project.where(developer: current_user, customer: contact)
        last_activity = [
          quotes.maximum(:updated_at),
          projects.maximum(:updated_at)
        ].compact.max

        {
          user:            contact,
          profile:         contact.customer_profile,
          quotes:          quotes,
          projects:        projects,
          total_value:     projects.sum(:total_amount),
          active_projects: projects.where(status: "active").count,
          last_activity:   last_activity,
          status:          projects.where(status: "active").any? ? :active :
                           quotes.where(status: "submitted").any? ? :prospect : :past,
        }
      end.sort_by { |c| c[:last_activity] || Time.at(0) }.reverse
    end

    private

    def require_developer!
      redirect_to root_path, alert: "Access denied." unless current_user.developer?
    end
  end
end