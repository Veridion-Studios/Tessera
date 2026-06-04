class AgencyDiscussion < ApplicationRecord
  belongs_to :agency
  belongs_to :author, class_name: "User"
  has_many   :messages, class_name: "AgencyDiscussionMessage", dependent: :destroy

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

class AgencyDiscussionMessage < ApplicationRecord
  belongs_to :discussion, class_name: "AgencyDiscussion"
  belongs_to :author,     class_name: "User"

  validates :body, presence: true

  after_create :update_discussion_timestamp

  private

  def update_discussion_timestamp
    discussion.update_column(:last_reply_at, created_at)
  end
end