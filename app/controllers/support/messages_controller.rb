module Support
  class MessagesController < ApplicationController
    def create
      @conversation = current_user.conversations.find(params[:support_id])
      @message = @conversation.messages.build(
        author: current_user,
        source: "web",
        body:   params[:message][:body]
      )

      if @message.save
        @conversation.update!(status: "open") if @conversation.waiting?
        redirect_to support_path(@conversation), notice: "Reply sent."
      else
        redirect_to support_path(@conversation), alert: "Couldn't send reply."
      end
    end
  end
end