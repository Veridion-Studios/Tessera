class AgencyProposal < ApplicationRecord
  belongs_to :agency
  belongs_to :quote_request

  STATUSES = %w[draft submitted accepted declined withdrawn].freeze
  validates :status, inclusion: { in: STATUSES }

  scope :active,    -> { where(status: %w[draft submitted]) }
  scope :submitted, -> { where(status: "submitted") }

  def submitted?
    status == "submitted"
  end

  def editable?
    status == "draft"
  end
end