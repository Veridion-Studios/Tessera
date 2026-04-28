class PortfolioSubmission < ApplicationRecord
  belongs_to :user
  has_paper_trail

  URL_REGEX = /\Ahttps?:\/\/.+/i
  GITHUB_REPO_REGEX = /\Ahttps:\/\/github\.com\/[A-Za-z0-9_.-]+\/[A-Za-z0-9_.-]+\/?\z/

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
  validates :title, :github_repo_url, presence: true
  validates :github_repo_url, format: { with: GITHUB_REPO_REGEX, message: "must be a valid GitHub repository URL" }
  validates :project_demo_url, format: { with: URL_REGEX, message: "must be a valid URL" }, allow_blank: true

  # Keep reads/writes working across deploys where app/db schema may be briefly out of sync.
  def github_repo_url
    if self.class.column_names.include?("github_repo_url")
      self[:github_repo_url]
    elsif self.class.column_names.include?("project_url")
      self[:project_url]
    end
  end

  def github_repo_url=(value)
    if self.class.column_names.include?("github_repo_url")
      self[:github_repo_url] = value
    elsif self.class.column_names.include?("project_url")
      self[:project_url] = value
    end
  end

  def project_demo_url
    if self.class.column_names.include?("project_demo_url")
      self[:project_demo_url]
    else
      @project_demo_url
    end
  end

  def project_demo_url=(value)
    if self.class.column_names.include?("project_demo_url")
      self[:project_demo_url] = value
    else
      @project_demo_url = value
    end
  end
end