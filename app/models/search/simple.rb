class Search::Simple
  attr_reader :catalog, :query, :page, :per

  def initialize(catalog:, query:, page:1, per:20)
    @catalog = catalog
    @query = query
    @page = [1, page.to_i].max
    @per = per
  end

  # TODO: test
  def offset
    per * (page - 1)
  end

  # TODO: test
  def page_for_offset(an_offset)
    1 + (an_offset / per)
  end

  def items_grouped_by_type
    return to_enum(__callee__) unless block_given?

    found_type_ids = unpaginated_items.pluck("items.item_type_id").uniq

    sorted_item_types.each do |type|
      next unless found_type_ids.include?(type.id)
      yield(type, type.items.merge(items))
    end
  end

  def items
    unpaginated_items.page(page).per(per)
  end

  private

  def unpaginated_items
    return Item.none if query.blank?
    catalog.items.simple_search(query)
  end

  def sorted_item_types
    catalog.item_types.includes(:fields).sorted
  end
end
