module Support
  class ConversationsController < ApplicationController
    def index
      @conversations = current_user.conversations.recent
    end

    def show
      @conversation = current_user.conversations.find(params[:id])
      @messages     = @conversation.messages.visible_to_user.includes(:author).order(:created_at)
      @message      = Message.new
    end

    def new
      @conversation = Conversation.new
    end

    def create
      @conversation = current_user.conversations.build(conversation_params)
      @conversation.status   = "open"
      @conversation.priority = "normal"

      if @conversation.save
        # First message is the body of the ticket
        @conversation.messages.create!(
          author: current_user,
          source: "web",
          body:   params[:message_body]
        )
        redirect_to support_path(@conversation), notice: "Support ticket created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def conversation_params
      params.require(:conversation).permit(:subject)
    end
  end
end