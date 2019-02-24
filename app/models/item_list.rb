# Base class for paginated lists of Items, e.g. search results.
class ItemList
  STYLES = {
    "thumb" => "items/thumbnails",
    "list" => "items/list",
    "grid" => "items/grid"
  }.freeze

  delegate :total_count, :to => :items
  delegate :empty?, :to => :unpaginaged_items

  attr_reader :catalog, :page, :per

  def initialize(catalog, page, per)
    @catalog = catalog
    self.page = page
    self.per = per || 24
  end

  def more?
    total_count > page * per
  end

  def page=(value)
    @page = [1, value.to_i].max
  end

  def per=(value)
    @per = [1, value.to_i].max
  end

  def offset
    per * (page - 1)
  end

  def page_for_offset(an_offset)
    1 + (an_offset.to_i / per)
  end

  def items
    unpaginated_list_items = unpaginaged_items.includes(:item_type)
                                              .includes(:item_type => :fields)
                                              .page(page)
                                              .per(per)

    item_type ||= unpaginated_list_items.first&.item_type
    return unpaginated_list_items if item_type.nil?

    item_type ||= (catalog.presence || @selected_catalog).item_types.first
    return unpaginated_list_items if item_type.primary_text_field.nil?

    unpaginated_list_items.order(Arel.sql("items.data->>'#{item_type.primary_text_field.uuid}'"))
  end
end
