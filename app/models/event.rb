class Event < ApplicationRecord
  has_many :event_votes, dependent: :destroy
  has_one :event_vote_counter, dependent: :destroy

  # direction :up or :down — toggles matching vote button; switches count when flipping.
  def apply_vote_toggle!(clerk_user_id:, direction:)
    dir = direction.to_sym
    raise ArgumentError, direction unless %i[up down].include?(dir)

    transaction do
      counter = EventVoteCounter.find_or_initialize_by(event_id: id)
      counter.upvotes_count ||= 0
      counter.downvotes_count ||= 0
      counter.save! if counter.new_record?

      vote = event_votes.find_by(clerk_user_id: clerk_user_id)

      case
      when vote.nil?
        if dir == :up
          event_votes.create!(clerk_user_id: clerk_user_id, vote_type: "upvote")
          counter.increment!(:upvotes_count)
        else
          event_votes.create!(clerk_user_id: clerk_user_id, vote_type: "downvote")
          counter.increment!(:downvotes_count)
        end
      when vote.vote_type == "upvote" && dir == :up
        vote.destroy!
        counter.decrement!(:upvotes_count)
      when vote.vote_type == "downvote" && dir == :down
        vote.destroy!
        counter.decrement!(:downvotes_count)
      when vote.vote_type == "downvote" && dir == :up
        vote.update!(vote_type: "upvote")
        counter.update!(
          downvotes_count: counter.downvotes_count - 1,
          upvotes_count: counter.upvotes_count + 1
        )
      when vote.vote_type == "upvote" && dir == :down
        vote.update!(vote_type: "downvote")
        counter.update!(
          upvotes_count: counter.upvotes_count - 1,
          downvotes_count: counter.downvotes_count + 1
        )
      end

      counter.reload
      update_column(:vote_count, counter.upvotes_count + counter.downvotes_count)
    end

    reload
  end
end
