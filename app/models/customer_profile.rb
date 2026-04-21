class CustomerProfile < ApplicationRecord
  belongs_to :user
  has_paper_trail

  IDENTITY_STATUSES = %w[unverified verified].freeze

  validates :identity_status, inclusion: { in: IDENTITY_STATUSES }

  def verified? = identity_status == "verified"
end