require 'net/http'
require 'uri'
require 'json'

namespace :bugsnag do
  desc "Notify Bugsnag of a new deploy"
  task :deploy do
    api_key     = ENV['BUGSNAG_API_KEY']     || raise("BUGSNAG_API_KEY is required")
    app_version = ENV['BUGSNAG_APP_VERSION'] || ENV['APP_VERSION'] || "unknown"

    uri = URI.parse("https://build.bugsnag.com/")

    body = {
      apiKey: api_key,
      appVersion: app_version,
      releaseStage: Rails.env,
      builderName: ENV['BUILDER'] || "Rails Rake Task"
    }

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    req = Net::HTTP::Post.new(uri.request_uri)
    req['Content-Type'] = 'application/json'
    req.body = body.to_json

    response = http.request(req)

    if response.is_a?(Net::HTTPSuccess)
      puts "✅ Bugsnag deploy notification sent."
    else
      puts "❌ Bugsnag deploy failed: #{response.code} #{response.body}"
    end
  end
end
