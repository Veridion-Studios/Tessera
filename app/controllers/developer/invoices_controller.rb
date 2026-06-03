module Developer
  class InvoicesController < ApplicationController
    before_action :authenticate_user!
    before_action :require_developer!
    before_action :set_invoice, only: [:show, :edit, :update, :destroy, :send_invoice, :mark_paid, :void]

    def index
      @invoices   = Invoice.where(developer: current_user).includes(:client, :line_items).order(created_at: :desc)
      @total_paid    = @invoices.where(status: "paid").sum(:total)
      @total_pending = @invoices.where(status: %w[sent overdue]).sum(:total)
      @total_overdue = @invoices.where(status: "sent").where("due_date < ?", Date.today).sum(:total)
    end

    def new
      @invoice = Invoice.new
      @invoice.line_items.build
    end

    def create
      @invoice = Invoice.new(invoice_params)
      @invoice.developer = current_user
      @invoice.status    = "draft"

      # compute totals
      compute_totals(@invoice)

      if @invoice.save
        sync_to_stripe(@invoice) if params[:sync_stripe] == "1"
        redirect_to developer_invoice_path(@invoice), notice: "Invoice created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def show
      @line_items = @invoice.line_items
    end

    def edit
      @invoice.line_items.build if @invoice.line_items.empty?
    end

    def update
      if @invoice.update(invoice_params)
        compute_totals(@invoice)
        @invoice.save
        redirect_to developer_invoice_path(@invoice), notice: "Invoice updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @invoice.destroy
      redirect_to developer_invoices_path, notice: "Invoice deleted."
    end

    def send_invoice
      @invoice.update!(status: "sent", sent_at: Time.current)
      # TODO: send email notification to client
      redirect_to developer_invoice_path(@invoice), notice: "Invoice sent."
    end

    def mark_paid
      @invoice.update!(status: "paid", paid_at: Time.current)
      redirect_to developer_invoice_path(@invoice), notice: "Invoice marked as paid."
    end

    def void
      @invoice.update!(status: "void", voided_at: Time.current)
      redirect_to developer_invoice_path(@invoice), notice: "Invoice voided."
    end

    private

    def set_invoice
      @invoice = Invoice.where(developer: current_user).find(params[:id])
    end

    def require_developer!
      redirect_to root_path, alert: "Access denied." unless current_user.developer?
    end

    def invoice_params
      params.require(:invoice).permit(
        :client_id, :project_id, :memo, :due_date,
        :tax_rate, :currency, :recurring, :recurrence_interval,
        line_items_attributes: [:id, :description, :quantity, :unit_amount, :_destroy]
      )
    end

    def compute_totals(invoice)
      subtotal = invoice.line_items.reject(&:marked_for_destruction?).sum { |li| li.quantity.to_i * li.unit_amount.to_d }
      invoice.subtotal = subtotal
      invoice.total    = subtotal + (subtotal * invoice.tax_rate.to_d)
    end

    def sync_to_stripe(invoice)
      # Stripe invoice creation — requires the client to have a Stripe customer ID
      return unless invoice.client.customer_profile&.stripe_customer_id.present?

      si = Stripe::Invoice.create({
        customer: invoice.client.customer_profile.stripe_customer_id,
        collection_method: "send_invoice",
        days_until_due: invoice.due_date ? [(invoice.due_date - Date.today).to_i, 1].max : 30,
        description: invoice.memo,
        metadata: { tessera_invoice_id: invoice.id }
      })

      invoice.line_items.each do |li|
        Stripe::InvoiceItem.create({
          customer:   invoice.client.customer_profile.stripe_customer_id,
          invoice:    si.id,
          amount:     (li.amount * 100).to_i,
          currency:   invoice.currency,
          description: li.description
        })
      end

      invoice.update_columns(stripe_invoice_id: si.id)
    rescue Stripe::StripeError => e
      Rails.logger.warn("Stripe invoice sync failed: #{e.message}")
    end
  end
end