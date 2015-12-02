class ExternalType::Client
  NotFound = Class.new(StandardError)

  def get(uri)
    conn.get(uri).body
  rescue Faraday::ResourceNotFound => e
    raise NotFound, e.message
  end

  private

  def conn
    @conn ||= Faraday.new do |c|
      c.response :raise_error
      c.response :json, :content_type => /\bjson$/
      c.response :logger, Rails.logger
      c.adapter Faraday.default_adapter
    end
  end
end
