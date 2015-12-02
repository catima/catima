class ExternalType::ClientWithCache < ExternalType::Client
  attr_reader :cache, :options

  def initialize(cache=Rails.cache, options={})
    @cache = cache
    @options = options.reverse_merge(:expires_in => 5.minutes)
  end

  def get(uri)
    cache.fetch("external-type:#{uri}", options) { super }
  end
end
