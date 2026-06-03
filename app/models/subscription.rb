class Subscription < ApplicationRecord
  belongs_to :developer, class_name: "User"
  belongs_to :client,    class_name: "User"

  has_paper_trail

  STATUSES   = %w[active paused cancelled past_due].freeze
  INTERVALS  = %w[week month year].freeze

  validates :status,   inclusion: { in: STATUSES }
  validates :interval, inclusion: { in: INTERVALS }
  validates :name,     presence: true
  validates :amount,   numericality: { greater_than: 0 }

  scope :active,    -> { where(status: "active") }
  scope :cancelled, -> { where(status: "cancelled") }

  def monthly_value
    case interval
    when "week"  then amount * 4.33
    when "month" then amount
    when "year"  then amount / 12
    end.round(2)
  end

  def stripe_synced?
    stripe_subscription_id.present?
  end
end