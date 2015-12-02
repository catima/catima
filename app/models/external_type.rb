class ExternalType
  attr_reader :url, :client

  def initialize(url, client: ExternalType::ClientWithCache.new)
    @url = url + (url.ends_with?("/") ? "" : "/")
    @client = client
  end

  def name(locale=I18n.locale)
    json["item_name"][locale.to_s]
  end

  def locales
    json["locales"]
  end

  def find_item(id)
    item_json = get("items", id)
    ExternalType::Item.from_json(item_json)
  end

  def all_items
    # TODO: support pagination
    @items ||= begin
      items_json = get("items")
      items_json["results"].map(&ExternalType::Item.method(:from_json))
    end
  end

  private

  def get(*path)
    client.get(url + path.join("/"))
  end

  def json
    @json ||= get
  end
end
