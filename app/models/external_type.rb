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
    # The service API supports loading an item by ID, but to deal with N+1
    # performance issues, we instead load all items and then find the item by
    # ID in memory. Assuming the underlying list of items is cached, this
    # should be faster in most cases where it matters.
    id = id.to_i
    all_items.find(-> { fail ExternalType::Client::NotFound }) do |item|
      item.id == id
    end
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
