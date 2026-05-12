class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :author, class_name: "User"

  has_rich_text :body

  validates :body, presence: true

  after_create :touch_conversation

  scope :visible_to_user, -> { where(internal: false) }

  def from_admin?
    author.admin?
  end

  private

  def touch_conversation
    conversation.update_columns(last_message_at: created_at)
  end
end