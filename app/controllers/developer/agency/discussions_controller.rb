module Developer
  module Agency
    class DiscussionsController < ApplicationController
      include Developer::AgencyScoped

      def index
        @internal_discussions = @agency.discussions.internal.recent
        @client_discussions   = @agency.discussions.client.recent
      end

      def show
        @discussion = @agency.discussions.find(params[:id])
        @messages   = @discussion.messages.includes(:author).order(:created_at)
        @message    = AgencyDiscussionMessage.new
      end

      def create
        @discussion = @agency.discussions.build(discussion_params)
        @discussion.author = current_user
        if @discussion.save
          redirect_to developer_agency_discussion_path(@discussion), notice: "Discussion started."
        else
          redirect_to developer_agency_discussions_path, alert: "Could not create discussion."
        end
      end

      def destroy
        @discussion = @agency.discussions.find(params[:id])
        @discussion.destroy
        redirect_to developer_agency_discussions_path, notice: "Discussion deleted."
      end

      private

      def discussion_params
        params.require(:agency_discussion).permit(:title, :visibility, :pinned)
      end
    end

    class DiscussionMessagesController < ApplicationController
      include Developer::AgencyScoped

      def create
        @discussion = @agency.discussions.find(params[:discussion_id])
        @message    = @discussion.messages.build(body: params[:agency_discussion_message][:body])
        @message.author = current_user
        if @message.save
          redirect_to developer_agency_discussion_path(@discussion), notice: "Reply posted."
        else
          redirect_to developer_agency_discussion_path(@discussion), alert: "Could not post reply."
        end
      end
    end
  end
end