class Conversation < ApplicationRecord
  belongs_to :user
  belongs_to :assigned_to, class_name: "User", optional: true
  has_many   :messages, dependent: :destroy

  has_paper_trail

  STATUSES   = %w[open waiting closed].freeze
  PRIORITIES = %w[low normal high urgent].freeze

  validates :subject,  presence: true
  validates :status,   inclusion: { in: STATUSES }
  validates :priority, inclusion: { in: PRIORITIES }

  scope :open,   -> { where(status: %w[open waiting]) }
  scope :closed, -> { where(status: "closed") }
  scope :recent, -> { order(last_message_at: :desc, created_at: :desc) }

  def open?   = status.in?(%w[open waiting])
  def waiting? = status == "waiting"
  def closed? = status == "closed"

  def status_color
    case status
    when "open"    then "text-green-400 border-green-500/20 bg-green-500/10"
    when "waiting" then "text-yellow-400 border-yellow-500/20 bg-yellow-500/10"
    when "closed"  then "text-zinc-500 border-white/8 bg-zinc-800"
    end
  end

  def priority_color
    case priority
    when "urgent" then "text-red-400 border-red-500/20 bg-red-500/10"
    when "high"   then "text-orange-400 border-orange-500/20 bg-orange-500/10"
    when "normal" then "text-zinc-400 border-white/8 bg-zinc-800"
    when "low"    then "text-zinc-500 border-white/8 bg-zinc-800/50"
    end
  end
end