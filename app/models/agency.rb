class Agency < ApplicationRecord
  belongs_to :owner, class_name: "User"
  has_many :memberships,   class_name: "AgencyMembership", dependent: :destroy
  has_many :members,       through: :memberships, source: :user
  has_many :projects

  has_many :milestones,    class_name: "AgencyMilestone",          dependent: :destroy
  has_many :discussions,   class_name: "AgencyDiscussion",         dependent: :destroy
  has_many :files,         class_name: "AgencyFile",               dependent: :destroy
  has_many :proposals,     class_name: "AgencyProposal",           dependent: :destroy

  has_one_attached :logo

  validates :name,       presence: true
  validates :slug,       uniqueness: true, allow_nil: true,
                         format: { with: /\A[a-z0-9\-]{3,40}\z/, allow_nil: true }
  validates :visibility, inclusion: { in: %w[private public whitelabel] }

  before_save :normalize_slug

  VISIBILITIES = %w[private public whitelabel].freeze

  # ── Membership helpers ───────────────────────────────────────────────────

  def member?(user)
    memberships.exists?(user: user, deactivated_at: nil)
  end

  def admin?(user)
    memberships.exists?(user: user, role: %w[owner admin], deactivated_at: nil)
  end

  # ── Financial ────────────────────────────────────────────────────────────

  def total_revenue
    projects.sum(:amount_released)
  end

  def this_month_revenue
    projects.where(updated_at: Time.current.beginning_of_month..).sum(:amount_released)
  end

  # ── Capacity ─────────────────────────────────────────────────────────────

  def team_capacity_summary
    active = memberships.active.includes(:user)
    {
      total:          active.count,
      available_now:  active.where(bench_status: "available_now").count,
      at_capacity:    active.where("capacity_pct >= ?", 90).count,
      avg_capacity:   active.average(:capacity_pct)&.round || 0
    }
  end

  # ── Revenue splits ───────────────────────────────────────────────────────

  def revenue_splits_configured?
    memberships.active.where("revenue_share_pct > 0").exists?
  end

  def total_allocated_revenue_pct
    (memberships.active.sum(:revenue_share_pct) * 100).round(1)
  end

  # ── Skill coverage ───────────────────────────────────────────────────────

  def all_specialty_tags
    memberships.active.pluck(:specialty_tags).flatten.uniq.compact.sort
  end

  private

  def normalize_slug
    self.slug = slug.presence&.downcase&.strip&.gsub(/[^a-z0-9\-]/, "-")
  end
end