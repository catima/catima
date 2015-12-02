class ExternalType
  attr_reader :url, :client

  def initialize(url, client: ExternalType::ClientWithCache.new)
    @url = url
    @client = client
  end

  def name(locale=I18n.locale)
    json["item_name"][locale.to_s]
  end

  def locales
    json["locales"]
  end

  def items
    # TODO: support pagination
    @items ||= begin
      items_url = url + (url.ends_with?("/") ? "" : "/") + "items"
      items_json = client.get(items_url)
      items_json["results"].map(&ExternalType::Item.method(:from_json))
    end
  end

  private

  def json
    @json ||= client.get(url)
  end
end
