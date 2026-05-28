class DevlogEntry < ApplicationRecord
  belongs_to :project
  belongs_to :author, class_name: "User"
  belongs_to :milestone, class_name: "ProjectMilestone", optional: true

  has_rich_text :body_rich
  has_many_attached :attachments

  has_paper_trail

  KINDS = %w[update commit file milestone_submit milestone_approve].freeze
  validates :kind, inclusion: { in: KINDS }
  validates :body, presence: true

  default_scope { order(created_at: :desc) }
end