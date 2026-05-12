class EventsController < ApplicationController
  before_action :require_clerk_login_for_voting, only: %i[upvote downvote]

  def index
    @events = Event.includes(:event_vote_counter).order(start_at: :desc).page(params[:page]).per(12)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def upvote
    Rails.configuration.event_store.publish(
      Vote::VoteEvent.new(
        data: {
          event_id: params[:id],
          clerk_user_id: current_clerk_user.id,
          vote_type: EventVote::VoteType::UPVOTE
        },
        metadata: {
          ip: Current.request_ip
        }
      )
    )

    redirect_to events_path(page: params[:page]), notice: "Thanks for your vote."
  end

  def downvote
    Rails.configuration.event_store.publish(
      Vote::VoteEvent.new(
        data: {
          event_id: params[:id],
          clerk_user_id: current_clerk_user.id,
          vote_type: EventVote::VoteType::DOWNVOTE
        }
      )
    )

    redirect_to events_path(page: params[:page]), notice: "Thanks for your vote."
  end

  private

  def require_clerk_login_for_voting
    return if clerk_signed_in?

    redirect_to events_path(page: params[:page]), alert: "Sign in with Clerk to vote on events."
  end
end
