module Vote
  class VoteEvent
    def initialize(clerk_user_id:, event_id:, vote_type:)
      @clerk_user_id = clerk_user_id
      @event_id = event_id
      @vote_type = vote_type
    end
  
    def call
      existing_vote = Vote.find_by(
        clerk_user_id: @clerk_user_id,
        event_id: @event_id
      )

      # if the vote already exists, return
      return if existing_vote&.vote_type == @vote_type
        
  
      ActiveRecord::Base.transaction do

        vote = EventVote.upsert(
          {
            clerk_user_id: @user.clerk_user_id,
            event_id: @event.id,
            value: @vote_type
          },
          unique_by: [:user_id, :event_id]
        )
  
        # @event.increment!(:upvotes_count)
  
        Rails.configuration.event_store.publish(
          EventVoted.new(
            data: {
              clerk_user_id: @user.clerk_user_id,
              event_id: @event.id,
              vote_type: @vote_type
            },
            metadata: {
              ip: Current.request_ip
            }
          )
        )
      end
    end
  end
end
