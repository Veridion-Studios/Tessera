module Developer
  class QuotesController < ApplicationController
    before_action :authenticate_user!
    before_action :require_developer!
    before_action :set_quote, only: [:show, :accept, :decline, :counter, :message]

    def index
      @status = params[:status] || "open"
      @quotes = if @status == "open"
        current_user.received_quote_requests.active.recent.includes(:customer)
      else
        current_user.received_quote_requests.where(status: %w[accepted declined withdrawn completed expired]).recent.includes(:customer)
      end
    end

    def show
      @quote.mark_viewed! if @quote.submitted?
      @messages   = @quote.thread_messages.chronological.includes(:author)
      @milestones = @quote.milestones.ordered
      @quote.thread_messages.where(read_by_developer: false).update_all(read_by_developer: true)
    end

    def accept
      agreed_amount   = params[:agreed_amount].presence&.to_d
      agreed_timeline = params[:agreed_timeline].presence
      start_date      = params[:start_date].presence&.to_date
      end_date        = params[:end_date].presence&.to_date

      @quote.accept!(
        agreed_amount:   agreed_amount,
        agreed_timeline: agreed_timeline,
        start_date:      start_date,
        end_date:        end_date
      )

      @quote.thread_messages.create!(
        author: current_user,
        kind:   "acceptance",
        body:   params[:note].presence || "Accepted."
      )

      QuoteRespondedNotification
        .with(
          action:        "accepted",
          developer_name: current_user.email.split("@").first,
          title:          @quote.title,
          quote_id:       @quote.id
        )
        .deliver(@quote.customer)

      redirect_to developer_quote_path(@quote), notice: "Quote accepted."
    end

    def decline
      @quote.decline!
      @quote.thread_messages.create!(
        author: current_user,
        kind:   "decline",
        body:   params[:reason].presence || "Declined."
      )

      QuoteRespondedNotification
        .with(
          action:         "declined",
          developer_name: current_user.email.split("@").first,
          title:          @quote.title,
          quote_id:       @quote.id
        )
        .deliver(@quote.customer)

      redirect_to developer_quote_path(@quote), notice: "Quote declined."
    end

    def counter
      @quote.enter_negotiation!
      @quote.thread_messages.create!(
        author:            current_user,
        kind:              "counter_proposal",
        body:              params[:body],
        proposed_amount:   params[:proposed_amount].presence&.to_d,
        proposed_timeline: params[:proposed_timeline].presence,
        proposed_start_date: params[:proposed_start_date].presence&.to_date,
        proposed_end_date:   params[:proposed_end_date].presence&.to_date
      )

      QuoteRespondedNotification
        .with(
          action:         "sent a counter-proposal on",
          developer_name: current_user.email.split("@").first,
          title:          @quote.title,
          quote_id:       @quote.id
        )
        .deliver(@quote.customer)

      redirect_to developer_quote_path(@quote), notice: "Counter-proposal sent."
    end

    def message
      msg = @quote.thread_messages.build(
        author: current_user,
        kind:   "message",
        body:   params[:body]
      )
      if msg.save
        @quote.enter_negotiation! if @quote.submitted? || @quote.viewed?
        QuoteMessageNotification
          .with(title: @quote.title, quote_id: @quote.id, recipient_role: "customer")
          .deliver(@quote.customer)
        redirect_to developer_quote_path(@quote)
      else
        redirect_to developer_quote_path(@quote), alert: "Message can't be blank."
      end
    end

    private

    def require_developer!
      redirect_to root_path, alert: "Access denied." unless current_user.developer?
    end

    def set_quote
      @quote = current_user.received_quote_requests.find(params[:id])
    end
  end
end