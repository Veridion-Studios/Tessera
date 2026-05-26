module Client
  class QuotesController < ApplicationController
    before_action :authenticate_user!
    before_action :require_customer!
    before_action :set_quote, only: [:show, :withdraw, :message]

    def index
      @quotes = current_user.sent_quote_requests.recent
                  .includes(:developer)
    end

    def new
      @quote    = QuoteRequest.new
      @developer = find_developer
    end

    def create
      @developer = User.find(params[:quote_request][:developer_id])
      @quote = QuoteRequest.new(quote_params)
      @quote.customer    = current_user
      @quote.developer   = @developer
      @quote.status      = "submitted"
      @quote.submitted_at = Time.current
      @quote.expires_at  = 7.days.from_now

      if @quote.save
        # System message logging the submission
        @quote.thread_messages.create!(
          author: current_user,
          kind:   "system",
          body:   "Quote request submitted."
        )

        QuoteReceivedNotification
          .with(
            title:          @quote.title,
            customer_email: current_user.email,
            quote_id:       @quote.id
          )
          .deliver(@developer)

        redirect_to client_quote_path(@quote), notice: "Quote request sent to #{@developer.email.split('@').first}."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def show
      @messages   = @quote.thread_messages.chronological.includes(:author)
      @milestones = @quote.milestones.ordered
      # Mark thread messages as read by customer
      @quote.thread_messages.where(read_by_customer: false).update_all(read_by_customer: true)
    end

    def withdraw
      @quote.withdraw!
      @quote.thread_messages.create!(
        author: current_user,
        kind:   "system",
        body:   "Quote request withdrawn by client."
      )
      redirect_to client_quote_path(@quote), notice: "Quote withdrawn."
    end

    def message
      msg = @quote.thread_messages.build(
        author: current_user,
        kind:   "message",
        body:   params[:body]
      )
      if msg.save
        @quote.enter_negotiation!
        QuoteMessageNotification
          .with(title: @quote.title, quote_id: @quote.id, recipient_role: "developer")
          .deliver(@quote.developer)
        redirect_to client_quote_path(@quote)
      else
        redirect_to client_quote_path(@quote), alert: "Message can't be blank."
      end
    end

    private

    def require_customer!
      redirect_to root_path, alert: "Access denied." unless current_user.customer?
    end

    def set_quote
      @quote = current_user.sent_quote_requests.find(params[:id])
    end

    def find_developer
      User.find(params[:developer_id]) if params[:developer_id]
    end

    def quote_params
      params.require(:quote_request).permit(
        :developer_id, :title, :description,
        :budget_min, :budget_max, :timeline, :engagement_type,
        tech_tags: []
      )
    end
  end
end