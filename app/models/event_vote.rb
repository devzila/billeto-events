class EventVote < ApplicationRecord
    belongs_to :event
    validates :clerk_user_id, presence: true
    validates :vote_type, presence: true
    enum :vote_type, { upvote: 1, downvote: -1 }
end
