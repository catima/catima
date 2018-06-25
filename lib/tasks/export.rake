namespace :export do
  desc "Check catalog exports validity and delete export files when expired"
  task remove_expired: [:environment] do
    # Check all the exports created more than 1 week ago
    exports = Export.where("created_at < ?", Export.validity.ago).where(:file => true)

    # Remove all expired export files but keep the db records
    exports.each do |export|
      FileUtils.rm_f(export.pathname)
      export.update(file: false)
    end
  end
end
