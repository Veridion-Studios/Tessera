module Developer
  class ProjectsController < ApplicationController
    before_action :authenticate_user!
    before_action :require_developer!
    before_action :set_project, only: [:show, :escrow_status]

    def index
      @active    = Project.where(developer: current_user, status: "active").includes(:customer, :milestones).order(created_at: :desc)
      @paused    = Project.where(developer: current_user, status: "paused").includes(:customer, :milestones).order(created_at: :desc)
      @completed = Project.where(developer: current_user, status: "completed").includes(:customer).order(completed_at: :desc).limit(10)
    end

    def show
      @milestones  = @project.milestones.order(:position)
      @devlogs     = @project.devlog_entries.includes(:author, :milestone).order(created_at: :desc).limit(20)
      @escrow_txs  = @project.escrow_transactions.order(created_at: :desc)

      @payment_intent = fetch_payment_intent
      @transfers      = fetch_milestone_transfers(@milestones)
    end

    def escrow_status
      @payment_intent = fetch_payment_intent
      @milestones     = @project.milestones.order(:position)
      @transfers      = fetch_milestone_transfers(@milestones)
      render partial: "escrow_status_panel", locals: { project: @project, payment_intent: @payment_intent, transfers: @transfers, milestones: @milestones }
    end

    private

    def set_project
      @project = Project.where(developer: current_user).find(params[:id])
    end

    def require_developer!
      redirect_to root_path, alert: "Access denied." unless current_user.developer?
    end

    def fetch_payment_intent
      return nil if @project.stripe_payment_intent_id.blank?
      Stripe::PaymentIntent.retrieve(@project.stripe_payment_intent_id)
    rescue Stripe::StripeError => e
      Rails.logger.warn("PaymentIntent fetch failed for project #{@project.id}: #{e.message}")
      nil
    end

    def fetch_milestone_transfers(milestones)
      milestones.each_with_object({}) do |ms, hash|
        next if ms.stripe_transfer_id.blank?
        begin
          hash[ms.id] = Stripe::Transfer.retrieve(ms.stripe_transfer_id)
        rescue Stripe::StripeError => e
          Rails.logger.warn("Transfer fetch failed for milestone #{ms.id}: #{e.message}")
          hash[ms.id] = nil
        end
      end
    end
  end
end