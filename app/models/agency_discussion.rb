class AgencyDiscussion < ApplicationRecord
  belongs_to :agency
  belongs_to :author, class_name: "User"
  has_many   :messages, class_name: "AgencyDiscussionMessage", foreign_key: :discussion_id, dependent: :destroy

  VISIBILITIES = %w[internal client].freeze
  validates :title,      presence: true
  validates :visibility, inclusion: { in: VISIBILITIES }

  scope :internal, -> { where(visibility: "internal") }
  scope :client,   -> { where(visibility: "client") }
  scope :pinned,   -> { where(pinned: true) }
  scope :recent,   -> { order(last_reply_at: :desc, created_at: :desc) }

  def reply_count
    messages.count
  end
end