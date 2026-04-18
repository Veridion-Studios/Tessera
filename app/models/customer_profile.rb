class CustomerProfile < ApplicationRecord
  belongs_to :user

  IDENTITY_STATUSES = %w[unverified verified].freeze

  validates :identity_status, inclusion: { in: IDENTITY_STATUSES }

  def verified?
    identity_status == "verified"
  end
end