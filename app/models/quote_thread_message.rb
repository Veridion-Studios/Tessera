class QuoteThreadMessage < ApplicationRecord
  belongs_to :quote_request, foreign_key: :quote_request_id, inverse_of: :thread_messages
  belongs_to :author, class_name: "User"

  KINDS = %w[message counter_proposal acceptance decline milestone_proposal system].freeze

  validates :kind, inclusion: { in: KINDS }
  validates :body, presence: true, if: -> { kind == "message" }

  scope :chronological, -> { order(:created_at) }

  def from_customer?
    author_id == quote_request.customer_id
  end

  def from_developer?
    author_id == quote_request.developer_id
  end

  def system?    = kind == "system"
  def proposal?  = kind == "counter_proposal"
  def milestone? = kind == "milestone_proposal"
end