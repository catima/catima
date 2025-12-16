module DailyItem
  def fetch_daily_item_data
    # Check if the attributes of the daily item are already cached for today
    Rails.cache.fetch("objetslitt_daily_item_data", expires_in: time_until_end_of_day) do
      # If the cache is not set or expired, get a new object and store its data in the cache
      set_daily_item_data
    end
  end

  private

  def set_daily_item_data
    # Get the ItemType for the "objets" type
    objet_type = ItemType.where(catalog_id: @catalog.id).find_by(slug: "objets")

    # Get a random item of type "objets"
    random_item = Item.where(item_type_id: objet_type.id).order("RANDOM()").limit(1).first

    return nil if random_item.nil?

    # Find fields UUIDS
    nom = objet_type.find_field("nom").uuid
    cover = objet_type.find_field("cover").uuid

    # Extract the necessary attributes from the random item
    data = {}
    data[:name] = random_item.data[nom]
    cover_path = random_item.data[cover]&.dig("path")
    data[:cover] = cover_path ? "/" + cover_path : nil
    data[:url] = "/objetslitt/#{I18n.locale}/objets/#{random_item.id}"

    data
  end

  def time_until_end_of_day
    # Makes sure that the cached item data expires every day at midnight.
    # Calculate the time remaining until the end of the day (23:59:59)
    Time.zone.now.end_of_day - Time.zone.now
  end
end
