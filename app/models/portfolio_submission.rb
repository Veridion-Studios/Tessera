class PortfolioSubmission < ApplicationRecord
  belongs_to :user
  has_paper_trail

  STATUSES = %w[pending approved rejected].freeze

  validates :status,       inclusion: { in: STATUSES }
  validates :title, :project_url, presence: true
end