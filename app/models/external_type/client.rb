class ExternalType::Client
  InvalidFormat = Class.new(StandardError)
  NotFound = Class.new(StandardError)

  def get(uri)
    parse_json_with_workaround(conn.get(uri))
  rescue Faraday::ResourceNotFound => e
    raise NotFound, e.message
  end

  private

  def parse_json_with_workaround(response)
    fail InvalidFormat unless response[:content_type] =~ /\bjson\b/

    JSON.parse(response.body)
  end

  def conn
    @conn ||= Faraday.new do |c|
      c.response :raise_error
      # TODO: re-enable after removing above workaround
      # c.response :json, :content_type => /\bjson$/
      c.response :logger, Rails.logger
      c.adapter Faraday.default_adapter
    end
  end
end
