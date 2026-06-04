module Developer
  module Agency
    class SettingsController < ApplicationController
      include Developer::AgencyScoped
      before_action :require_agency_admin!

      def show
      end

      def update
        if @agency.update(settings_params)
          redirect_to developer_agency_settings_path, notice: "Settings saved."
        else
          render :show, status: :unprocessable_entity
        end
      end

      private

      def settings_params
        params.require(:agency).permit(
          :name, :tagline, :bio, :website_url,
          :slug, :cover_image_url, :founded_on,
          :visibility, :logo
        )
      end
    end
  end
end