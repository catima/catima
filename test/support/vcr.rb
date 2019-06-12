
VCR.configure do |config|
  config.allow_http_connections_when_no_cassette = true
  config.cassette_library_dir = File.expand_path("../../cassettes", __FILE__)
  config.hook_into :webmock
  config.ignore_localhost = true
  config.default_cassette_options = { :record => :new_episodes }
end

module WithVCR
  private

  def with_vcr_cassette
    names = self.class.name.split("::")
    cassette_path = names.map { |s| s.gsub(/[^A-Z0-9]+/i, "_") }.join("/")

    VCR.use_cassette(cassette_path) do |cassette|
      yield(cassette)
    end
  end
end
