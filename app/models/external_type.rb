class ExternalType
  attr_reader :url, :client

  def initialize(url, client: ExternalType::ClientWithCache.new)
    @url = url
    @client = client
  end

  def valid?
    expected = %w(locales item_name fields)
    (expected - json.keys).empty?
  rescue ExternalType::Client::InvalidFormat, ExternalType::Client::NotFound
    false
  end

  def name(locale=I18n.locale)
    json["item_name"][locale.to_s]
  end

  def locales
    json["locales"]
  end

  def find_item(id)
    item_json = get("items", id.to_i.to_s)
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
    full_url = url
    full_url << "/" if path.present? && !url.ends_with?("/")
    full_url << path.join("/")
    client.get(full_url)
  end

  def json
    @json ||= get
  end
end

require_dependency("external_type/item")
