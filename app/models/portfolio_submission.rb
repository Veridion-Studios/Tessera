class PortfolioSubmission < ApplicationRecord
  belongs_to :user

  STATUSES = %w[pending approved rejected].freeze
  TECH_TAGS = %w[
    Ruby Rails Python Django JavaScript TypeScript React Svelte Vue
    Node.js PostgreSQL MySQL Redis Docker AWS GCP Azure GraphQL REST
    Swift Kotlin Flutter iOS Android
  ].freeze

  validates :project_url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL" }
  validates :title, presence: true
  validates :status, inclusion: { in: STATUSES }
  validate :tech_tags_are_valid

  private

  def tech_tags_are_valid
    invalid = tech_tags - TECH_TAGS
    errors.add(:tech_tags, "contains invalid tags: #{invalid.join(', ')}") if invalid.any?
  end
end