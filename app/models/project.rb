class Project < ApplicationRecord
  belongs_to :quote_request
  belongs_to :developer, class_name: "User"
  belongs_to :customer,  class_name: "User"

  has_many :milestones,         class_name: "ProjectMilestone", dependent: :destroy
  has_many :devlog_entries,     dependent: :destroy
  has_many :escrow_transactions, dependent: :destroy

  has_paper_trail

  STATUSES       = %w[active paused completed cancelled disputed].freeze
  PAYMENT_TYPES  = %w[milestone fixed].freeze
  ESCROW_STATUSES = %w[unfunded funded partially_released released refunded].freeze

  validates :status,        inclusion: { in: STATUSES }
  validates :payment_type,  inclusion: { in: PAYMENT_TYPES }
  validates :escrow_status, inclusion: { in: ESCROW_STATUSES }

  # Full Stripe response stored as JSON for audit / debugging.
  # e.g. project.stripe_metadata["payment_intent"] => { "id" => "pi_...", "status" => "requires_capture", ... }
  store_accessor :stripe_metadata,
                 :payment_intent_object,
                 :transfer_object,
                 :charge_object

  scope :active,    -> { where(status: "active") }
  scope :completed, -> { where(status: "completed") }

  def platform_fee_amount
    (total_amount * platform_fee_pct).round(2)
  end

  def developer_payout_amount
    total_amount - platform_fee_amount
  end

  def funded?
    escrow_status.in?(%w[funded partially_released])
  end

  def completion_percentage
    return 0 if milestones.empty?
    paid = milestones.where(status: "paid").count
    (paid.to_f / milestones.count * 100).round
  end
end