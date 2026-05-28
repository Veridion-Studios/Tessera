class ProjectMilestone < ApplicationRecord
  belongs_to :project
  has_many :devlog_entries, foreign_key: :milestone_id, dependent: :nullify
  has_many :escrow_transactions, foreign_key: :milestone_id, dependent: :nullify

  has_paper_trail

  STATUSES = %w[pending in_progress submitted approved paid disputed].freeze
  validates :status, inclusion: { in: STATUSES }

  default_scope { order(:position) }

  def payable?
    status == "approved" && stripe_transfer_id.nil?
  end
end