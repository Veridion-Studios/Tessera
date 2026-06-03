class Invoice < ApplicationRecord
  belongs_to :developer, class_name: "User"
  belongs_to :client,    class_name: "User"
  belongs_to :project, optional: true

  has_many :line_items, class_name: "InvoiceLineItem", dependent: :destroy

  has_paper_trail

  STATUSES = %w[draft sent paid void overdue].freeze
  validates :status, inclusion: { in: STATUSES }

  scope :unpaid,    -> { where(status: %w[sent overdue]) }
  scope :overdue,   -> { where(status: "sent").where("due_date < ?", Date.today) }
  scope :recurring, -> { where(recurring: true) }

  def overdue?
    status == "sent" && due_date.present? && due_date < Date.today
  end

  def tax_amount
    (subtotal * tax_rate).round(2)
  end

  def total_with_tax
    subtotal + tax_amount
  end

  def stripe_synced?
    stripe_invoice_id.present?
  end
end