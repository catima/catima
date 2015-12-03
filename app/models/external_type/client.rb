class ExternalType::Client
  NotFound = Class.new(StandardError)

  def get(uri)
    parse_json_with_workaround(conn.get(uri).body)
  rescue Faraday::ResourceNotFound => e
    raise NotFound, e.message
  end

  private

  # TODO: remove!
  # This remove the malformed next/previous keys before parsing.
  def parse_json_with_workaround(body)
    JSON.parse(body.gsub(/"(next|previous)": [^\s",]+,/, ""))
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
