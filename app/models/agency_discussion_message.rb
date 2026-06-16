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