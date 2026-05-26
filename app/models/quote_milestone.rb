class QuoteMilestone < ApplicationRecord
  belongs_to :quote_request, foreign_key: :quote_request_id, inverse_of: :milestones
  belongs_to :proposed_by, class_name: "User"

  STATUSES = %w[proposed accepted rejected completed paid].freeze

  validates :title,  presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: STATUSES }

  scope :ordered, -> { order(:position) }

  def status_color
    case status
    when "proposed"  then "text-yellow-400 border-yellow-500/20 bg-yellow-500/8"
    when "accepted"  then "text-green-400 border-green-500/20 bg-green-500/8"
    when "rejected"  then "text-red-400 border-red-500/20 bg-red-500/8"
    when "completed" then "text-primary border-primary/20 bg-primary/8"
    when "paid"      then "text-emerald-400 border-emerald-500/20 bg-emerald-500/8"
    end
  end
end