require "rails_event_store"

Rails.configuration.event_store = RailsEventStore::Client.new

Rails.application.config.after_initialize do
  Rails.configuration.event_store.subscribe(
    NotifyEventVoted.new, to: [Vote::EventVoted]
  )
end

