require_relative 'concerns/advisory_lock'

namespace :logs do
  desc "Check logs validity and delete them when expired"
  task remove_expired: :environment do
    AdvisoryLock.with_lock('logs:remove_expired') do
      # Retrieve all the entry_logs with an expired validity date and delete them
      entry_logs = EntryLog.where("created_at < ?", EntryLog.validity.ago)
      entry_logs.destroy_all

      # Retrieve all the api_logs with an expired validity date and delete them
      api_logs = APILog.where("created_at < ?", APILog.validity.ago)
      api_logs.destroy_all
    end
  end
end
