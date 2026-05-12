class NotifyEventVoted
 
  def call(event)
    event_id = event.data[:event_id]
    clerk_user_id = event.data[:clerk_user_id]

    # event = Event.find(event_id)
    # email will go to the event owner
  end
end