class PortfolioSubmission < ApplicationRecord
  belongs_to :user
  has_paper_trail

  STATUSES = %w[pending approved rejected].freeze
  TECH_TAGS = [
    "Ruby on Rails",
    "JavaScript",
    "TypeScript",
    "React",
    "Vue",
    "Node.js",
    "PostgreSQL",
    "Redis",
    "Docker",
    "AWS"
  ].freeze

  validates :status,       inclusion: { in: STATUSES }
  validates :title, :project_url, presence: true
end