class ItemsCacheWorker
  include Sidekiq::Worker

  def perform(catalog=nil, itemtype=nil, item_id=nil)
    item_types = item_id.nil? ? item_types(catalog, itemtype) : [Item.find(item_id).item_type]
    item_types.each do |it|
      cache_items_of_type(it, item_id)
    end
  end

  private

  def item_types(catalog, itemtype)
    return ItemType.all if catalog.nil?

    cat = Catalog.find_by(slug: catalog)
    return [] if cat.nil?

    itemtype.nil? ? cat.item_types : cat.item_types.where(slug: itemtype)
  end

  def cache_items_of_type(item_type, item_id=nil)
    item_view = item_type.default_display_name_view
    primary_field = item_type.field_for_select
    items = item_type.items
    items = items.where(id: item_id) unless item_id.nil?
    items.each do |itm|
      cache_item(itm, item_view, primary_field)
    end
  end

  def cache_item(item, item_view, primary_field)
    views = { display_name: {} }
    item.catalog.valid_locales.each do |locale|
      views[:display_name][locale] = item_view.nil? ? primary_field.strip_extra_content(item, locale) : item_view.render(item, locale, :display_name)
    end
    item.update!(views: views)
  end
end
