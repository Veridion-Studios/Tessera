module Admin
  module Support
    class ConversationsController < Admin::BaseController
      def index
        @status        = params[:status] || "open"
        @conversations = Conversation.where(status: @status == "open" ? %w[open waiting] : "closed")
                           .includes(:user, :messages)
                           .recent
      end

      def show
        @conversation = Conversation.find(params[:id])
        @messages     = @conversation.messages.includes(:author).order(:created_at)
        @message      = Message.new
      end

      def close
        @conversation = Conversation.find(params[:id])
        @conversation.update!(status: "closed")
        redirect_to admin_support_path(@conversation), notice: "Ticket closed."
      end

      def reopen
        @conversation = Conversation.find(params[:id])
        @conversation.update!(status: "open")
        redirect_to admin_support_path(@conversation), notice: "Ticket reopened."
      end

      def assign
        @conversation = Conversation.find(params[:id])
        @conversation.update!(assigned_to_id: params[:admin_id])
        redirect_to admin_support_path(@conversation), notice: "Assigned."
      end
    end
  end
end