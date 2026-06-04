class AgencyMilestone < ApplicationRecord
  belongs_to :agency
  belongs_to :project, optional: true

  STATUSES = %w[planned in_progress completed cancelled].freeze
  validates :title,  presence: true
  validates :status, inclusion: { in: STATUSES }

  scope :ordered,     -> { order(:position, :due_date) }
  scope :active,      -> { where(status: %w[planned in_progress]) }
  scope :upcoming,    -> { active.where("due_date >= ?", Date.current).order(:due_date) }
  scope :overdue,     -> { active.where("due_date < ?", Date.current) }

  def overdue?
    due_date.present? && due_date < Date.current && !%w[completed cancelled].include?(status)
  end

  def status_color
    case status
    when "planned"     then "text-zinc-400"
    when "in_progress" then "text-primary"
    when "completed"   then "text-success"
    when "cancelled"   then "text-zinc-600"
    end
  end
end