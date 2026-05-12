class SupportMailbox < ApplicationMailbox
  # Route: support@tessera.app, help@tessera.app
  # Match subject like "Re: [#abc123]" to thread replies into existing conversations

  REPLY_REGEX = /\[#([0-9a-f-]{36})\]/i

  def process
    if (match = mail.subject&.match(REPLY_REGEX))
      conversation_id = match[1]
      conversation = Conversation.find_by(id: conversation_id)
      if conversation
        thread_reply(conversation)
        return
      end
    end

    # New ticket from email
    user = User.find_by(email: mail.from.first)
    return unless user  # ignore email from unknown addresses

    conversation = user.conversations.create!(
      subject:  mail.subject.presence || "Support request",
      status:   "open",
      priority: "normal"
    )

    conversation.messages.create!(
      author: user,
      source: "email",
      body:   mail.decoded
    )
  end

  private

  def thread_reply(conversation)
    user = User.find_by(email: mail.from.first)
    author = user || conversation.user

    conversation.messages.create!(
      author: author,
      source: "email",
      body:   mail.decoded
    )

    conversation.update!(status: "open") if conversation.waiting?
  end
end