module Admin
  module Support
    class MessagesController < Admin::BaseController
      def create
        @conversation = Conversation.find(params[:support_id])
        @message = @conversation.messages.build(
          author:   current_user,
          source:   "web",
          internal: params[:message][:internal] == "1"
        )
        @message.body = params[:message][:body]

        if @message.save
          @conversation.update!(status: "waiting")

          # DISABLED: Support notifications
          # unless @message.internal?
          #   SupportReplyNotification
          #     .with(subject: @conversation.subject, conversation_id: @conversation.id)
          #     .deliver(@conversation.user)
          # end

          redirect_to admin_support_path(@conversation), notice: "Reply sent."
        else
          redirect_to admin_support_path(@conversation), alert: "Couldn't send reply."
        end
      end
    end
  end
end