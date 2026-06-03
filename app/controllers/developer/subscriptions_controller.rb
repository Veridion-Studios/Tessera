module Developer
  class SubscriptionsController < ApplicationController
    before_action :authenticate_user!
    before_action :require_developer!
    before_action :set_subscription, only: [:show, :edit, :update, :destroy, :cancel, :pause, :resume]

    def index
      @subscriptions = Subscription.where(developer: current_user).includes(:client).order(created_at: :desc)
      @monthly_recurring = @subscriptions.active.sum { |s| s.monthly_value }
    end

    def new
      @subscription = Subscription.new
    end

    def create
      @subscription = Subscription.new(subscription_params)
      @subscription.developer = current_user
      @subscription.status    = "active"
      @subscription.current_period_start = Time.current
      @subscription.current_period_end   = next_period_end(@subscription)

      if @subscription.save
        redirect_to developer_subscription_path(@subscription), notice: "Subscription created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def show; end

    def edit; end

    def update
      if @subscription.update(subscription_params)
        redirect_to developer_subscription_path(@subscription), notice: "Subscription updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @subscription.destroy
      redirect_to developer_subscriptions_path, notice: "Subscription removed."
    end

    def cancel
      @subscription.update!(status: "cancelled", cancelled_at: Time.current)
      redirect_to developer_subscriptions_path, notice: "Subscription cancelled."
    end

    def pause
      @subscription.update!(status: "paused", paused_at: Time.current)
      redirect_to developer_subscription_path(@subscription), notice: "Subscription paused."
    end

    def resume
      @subscription.update!(status: "active", paused_at: nil, current_period_start: Time.current,
                             current_period_end: next_period_end(@subscription))
      redirect_to developer_subscription_path(@subscription), notice: "Subscription resumed."
    end

    private

    def set_subscription
      @subscription = Subscription.where(developer: current_user).find(params[:id])
    end

    def require_developer!
      redirect_to root_path, alert: "Access denied." unless current_user.developer?
    end

    def subscription_params
      params.require(:subscription).permit(
        :client_id, :name, :description, :interval, :amount, :currency,
        :trial_end, :notes
      )
    end

    def next_period_end(sub)
      case sub.interval
      when "week"  then 1.week.from_now
      when "month" then 1.month.from_now
      when "year"  then 1.year.from_now
      end
    end
  end
end