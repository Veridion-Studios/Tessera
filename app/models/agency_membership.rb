class AgencyMembership < ApplicationRecord
  belongs_to :agency
  belongs_to :user

  ROLES = %w[owner admin member].freeze
  validates :role, inclusion: { in: ROLES }

  scope :active, -> { where(deactivated_at: nil) }

  def active?
    deactivated_at.nil? && accepted_at.present?
  end

  def pending?
    accepted_at.nil? && deactivated_at.nil?
  end
end