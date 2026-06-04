class AgencyMembership < ApplicationRecord
  belongs_to :agency
  belongs_to :user

  ROLES         = %w[owner admin member contractor].freeze
  BENCH_STATUSES = %w[available_now available_soon unavailable].freeze

  validates :role,         inclusion: { in: ROLES }
  validates :bench_status, inclusion: { in: BENCH_STATUSES }, allow_nil: true
  validates :capacity_pct, numericality: { in: 0..100 }, allow_nil: true

  scope :active,   -> { where(deactivated_at: nil) }
  scope :pending,  -> { where(accepted_at: nil, deactivated_at: nil) }
  scope :on_bench, -> { active.where(bench_status: %w[available_now available_soon]) }

  def active?
    deactivated_at.nil? && accepted_at.present?
  end

  def pending?
    accepted_at.nil? && deactivated_at.nil?
  end

  def display_name
    user.developer_profile&.display_name ||
      "#{user.preferred_first_name} #{user.preferred_last_name}".strip.presence ||
      user.email.split("@").first
  end

  def utilization_label
    return "Unknown" if capacity_pct.nil?
    case capacity_pct
    when 0..25  then "Light"
    when 26..60 then "Moderate"
    when 61..85 then "Heavy"
    else             "At capacity"
    end
  end

  def bench_label
    case bench_status
    when "available_now"  then "Available now"
    when "available_soon" then "Available soon"
    else                       "Unavailable"
    end
  end
end