class AgencyFile < ApplicationRecord
  belongs_to :agency
  belongs_to :uploader, class_name: "User"

  has_one_attached :attachment

  VISIBILITIES = %w[internal client].freeze
  validates :label,      presence: true
  validates :visibility, inclusion: { in: VISIBILITIES }

  scope :internal, -> { where(visibility: "internal") }
  scope :client,   -> { where(visibility: "client") }
  scope :recent,   -> { order(created_at: :desc) }
end