module Vote
  class VoteEvent
    def initialize(clerk_user_id:, event_id:, vote_type:, ip:)
      @clerk_user_id = clerk_user_id
      @event_id = event_id
      @vote_type = vote_type
      @ip = ip
    end
  
    # @return [Boolean] true if the vote was created or changed (counts updated)
    def call
      existing_vote = EventVote.find_by(
        clerk_user_id: @clerk_user_id,
        event_id: @event_id
      )

      return false if existing_vote && vote_type_matches?(existing_vote)

      ActiveRecord::Base.transaction do
        EventVote.upsert(
          {
            clerk_user_id: @clerk_user_id,
            event_id: @event_id,
            vote_type: @vote_type
          },
          unique_by: [:clerk_user_id, :event_id]
        )

        sync_event_vote_counter!(@event_id)

        Rails.configuration.event_store.publish(
          EventVoted.new(
            data: {
              clerk_user_id: @clerk_user_id,
              event_id: @event_id,
              vote_type: @vote_type
            },
            metadata: {
              ip: @ip
            }
          )
        )
      end

      true
    end

    private

    def vote_type_matches?(vote)
      case @vote_type
      when EventVote.vote_types[:upvote]
        vote.upvote?
      when EventVote.vote_types[:downvote]
        vote.downvote?
      else
        false
      end
    end

    def sync_event_vote_counter!(event_id)
      event = Event.find(event_id)
      upvotes = event.event_votes.where(vote_type: :upvote).count
      downvotes = event.event_votes.where(vote_type: :downvote).count

      counter = EventVoteCounter.find_or_initialize_by(event_id: event_id)
      counter.upvotes_count = upvotes
      counter.downvotes_count = downvotes
      counter.save!
    end
  end
end
