class EscrowTransaction < ApplicationRecord
  belongs_to :project
  belongs_to :milestone, class_name: "ProjectMilestone", optional: true

  KINDS = %w[fund release refund fee].freeze
  validates :kind, inclusion: { in: KINDS }

  default_scope { order(created_at: :desc) }
end