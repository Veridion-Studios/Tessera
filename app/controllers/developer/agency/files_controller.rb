module Developer
  module Agency
    class FilesController < ApplicationController
      include Developer::AgencyScoped

      def index
        @internal_files = @agency.files.internal.recent
        @client_files   = @agency.files.client.recent
      end

      def create
        @file = @agency.files.build(file_params)
        @file.uploader = current_user
        if @file.save
          redirect_to developer_agency_files_path, notice: "File uploaded."
        else
          redirect_to developer_agency_files_path, alert: "Could not upload file."
        end
      end

      def destroy
        @agency.files.find(params[:id]).destroy
        redirect_to developer_agency_files_path, notice: "File removed."
      end

      private

      def file_params
        params.require(:agency_file).permit(:label, :visibility, :attachment)
      end
    end
  end
end