namespace :swag do
  desc "Run Swagerize and generate responses from requests"
  task run: :environment do
    raise 'Exit code is not zero' unless system "SWAGGER_DRY_RUN=0 RAILS_ENV=test rails rswag"
  end
end
