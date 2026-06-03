class Agency < ApplicationRecord
  belongs_to :owner, class_name: "User"
  has_many :memberships, class_name: "AgencyMembership", dependent: :destroy
  has_many :members, through: :memberships, source: :user
  has_many :projects

  validates :name, presence: true

  def member?(user)
    memberships.exists?(user: user, deactivated_at: nil)
  end

  def admin?(user)
    memberships.exists?(user: user, role: %w[owner admin], deactivated_at: nil)
  end

  def total_revenue
    projects.sum(:amount_released)
  end
end