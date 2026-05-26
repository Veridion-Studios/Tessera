class QuoteRequest < ApplicationRecord
  belongs_to :customer,  class_name: "User", foreign_key: :customer_id
  belongs_to :developer, class_name: "User", foreign_key: :developer_id

  has_many :thread_messages, class_name: "QuoteThreadMessage",
                             foreign_key: :quote_request_id,
                             dependent: :destroy,
                             inverse_of: :quote_request
  has_many :milestones, class_name: "QuoteMilestone",
                        foreign_key: :quote_request_id,
                        dependent: :destroy,
                        inverse_of: :quote_request

  has_paper_trail

  STATUSES = %w[submitted viewed negotiating accepted declined withdrawn completed expired].freeze
  ENGAGEMENT_TYPES = %w[fixed hourly retainer].freeze

  validates :title,           presence: true
  validates :description,     presence: true
  validates :timeline,        presence: true
  validates :status,          inclusion: { in: STATUSES }
  validates :engagement_type, inclusion: { in: ENGAGEMENT_TYPES }

  scope :for_customer,  ->(user) { where(customer_id: user.id) }
  scope :for_developer, ->(user) { where(developer_id: user.id) }
  scope :active,   -> { where(status: %w[submitted viewed negotiating accepted]) }
  scope :recent,   -> { order(updated_at: :desc) }
  scope :unread_by_developer, -> { where(status: %w[submitted negotiating]) }

  # --- State helpers ---

  def submitted?   = status == "submitted"
  def viewed?      = status == "viewed"
  def negotiating? = status == "negotiating"
  def accepted?    = status == "accepted"
  def declined?    = status == "declined"
  def withdrawn?   = status == "withdrawn"
  def completed?   = status == "completed"
  def expired?     = status == "expired"
  def open?        = status.in?(%w[submitted viewed negotiating])
  def closed?      = status.in?(%w[accepted declined withdrawn completed expired])

  def mark_viewed!
    update!(status: "viewed", viewed_at: Time.current) if submitted?
  end

  def accept!(agreed_amount: nil, agreed_timeline: nil, start_date: nil, end_date: nil)
    update!(
      status: "accepted",
      accepted_at: Time.current,
      responded_at: Time.current,
      agreed_amount: agreed_amount,
      agreed_timeline: agreed_timeline,
      estimated_start_date: start_date,
      estimated_end_date: end_date
    )
  end

  def decline!
    update!(status: "declined", declined_at: Time.current, responded_at: Time.current)
  end

  def enter_negotiation!
    update!(status: "negotiating") if status.in?(%w[submitted viewed])
  end

  def withdraw!
    update!(status: "withdrawn") if open?
  end

  # --- Display helpers ---

  def budget_display
    if budget_min && budget_max
      "$#{budget_min.to_i.to_s(:delimited)} – $#{budget_max.to_i.to_s(:delimited)}"
    elsif budget_max
      "Up to $#{budget_max.to_i.to_s(:delimited)}"
    elsif budget_min
      "From $#{budget_min.to_i.to_s(:delimited)}"
    else
      "Budget TBD"
    end
  end

  def status_color
    case status
    when "submitted"   then "text-blue-400 border-blue-500/20 bg-blue-500/8"
    when "viewed"      then "text-yellow-400 border-yellow-500/20 bg-yellow-500/8"
    when "negotiating" then "text-violet-400 border-violet-500/20 bg-violet-500/8"
    when "accepted"    then "text-green-400 border-green-500/20 bg-green-500/8"
    when "declined"    then "text-red-400 border-red-500/20 bg-red-500/8"
    when "withdrawn"   then "text-zinc-500 border-white/8 bg-zinc-800"
    when "completed"   then "text-primary border-primary/20 bg-primary/8"
    when "expired"     then "text-zinc-600 border-white/5 bg-zinc-900"
    end
  end

  def status_label
    case status
    when "submitted"   then "Awaiting response"
    when "viewed"      then "Viewed"
    when "negotiating" then "Negotiating"
    when "accepted"    then "Accepted"
    when "declined"    then "Declined"
    when "withdrawn"   then "Withdrawn"
    when "completed"   then "Completed"
    when "expired"     then "Expired"
    end
  end

  def milestones_total
    milestones.sum(:amount)
  end
end