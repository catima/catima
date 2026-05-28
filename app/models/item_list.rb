# Base class for paginated lists of Items, e.g. search results.
class ItemList
  STYLES = {
    "thumb" => "items/thumbnails",
    "list" => "items/list",
    "grid" => "items/grid",
    "line" => "items/line"
  }.freeze

  # Default number of items per page
  PER = 24

  delegate :total_count, :to => :items
  delegate :empty?, :to => :unpaginaged_items

  attr_reader :catalog, :search_uuid, :page, :per

  def initialize(catalog, page, per)
    @catalog = catalog
    self.page = page
    self.per = per || PER
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
    @items ||= apply_sort(paginated_items).load
  end

  def paginated_items
    @paginated_items ||= unpaginaged_items.includes(:item_type => [:fields, :item_views])
                                          .page(page)
                                          .per(per)
  end

  def item_type
    @item_type ||= paginated_items.first&.item_type
  end

  # Returns the full unpaginated query with sorting applied.
  # This is used for navigation to allow traversing across page boundaries.
  def items_for_navigation
    @items_for_navigation ||= apply_sort(
      unpaginaged_items.includes(:item_type => [:fields, :item_views])
    )
  end

  private

  def apply_default_sort?
    true
  end

  def apply_sort(scope)
    return scope unless apply_default_sort?

    field = item_type&.field_for_select
    sorted = field.nil? ? scope : scope.sorted_by_field(field)
    sorted.order(:id)
  end
end
