class Search::Simple
  attr_reader :catalog, :query

  def initialize(catalog, query)
    @catalog = catalog
    @query = query
  end

  def items_grouped_by_type
    return to_enum(__callee__) unless block_given?

    found_type_ids = items.pluck("items.item_type_id").uniq

    sorted_item_types.each do |type|
      next unless found_type_ids.include?(type.id)
      yield(type, type.items.merge(items))
    end
  end

  def items
    return Item.none if query.blank?
    catalog.items.simple_search(query)
  end

  private

  def sorted_item_types
    catalog.item_types.includes(:fields).sorted
  end
end
