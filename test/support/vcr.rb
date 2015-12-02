require "vcr"

VCR.configure do |config|
  config.allow_http_connections_when_no_cassette = false
  config.cassette_library_dir = File.expand_path("../../cassettes", __FILE__)
  config.hook_into :webmock
  config.ignore_request { ENV["DISABLE_VCR"] }
  config.ignore_localhost = true
  config.default_cassette_options = {
    :record => :new_episodes
  }
end

class ActiveSupport::TestCase
  def self.test(test_name, &block)
    return super if block.nil?

    cassette = [name, test_name].map do |str|
      str.underscore.gsub(/[^A-Z]+/i, "_")
    end.join("/")

    super(test_name) do
      VCR.use_cassette(cassette) do
        instance_eval(&block)
      end
    end
  end
end
