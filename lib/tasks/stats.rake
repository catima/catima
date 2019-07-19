namespace :stats do
  desc "Check events & visits validity and delete them when expired"
  task remove_expired: :environment do
    # Retrieve all the events with an expired validity date and delete them
    events = Ahoy::Event.where("time < ?", Ahoy::Event.validity.ago)
    events.destroy_all

    # Retrieve all the visits with an expired validity date and delete them
    visits = Ahoy::Visit.where("started_at < ?", Ahoy::Visit.validity.ago)
    visits.destroy_all
  end
end
