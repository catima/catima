class ItemList::SimpleSearchResult < ItemList
  attr_reader :query, :item_type_slug

  def initialize(catalog:, query:, item_type_slug:nil, page:nil, per:nil)
    super(catalog, page, per)
    @query = query
    @item_type_slug = item_type_slug
  end

  # TODO: test
  def active_item_type
    sorted_item_types.find(&method(:active?))
  end

  # TODO: test
  def active?(item_type)
    return item_type.slug == item_type_slug if item_type_slug.present?

    most_results = item_counts_by_type.max_by(&:last)
    item_type.id == most_results.first.id unless most_results.nil?
  end

  def item_counts_by_type
    return to_enum(__callee__) unless block_given?

    found_type_ids = relation.pluck("items.item_type_id").uniq
    sorted_item_types.each do |type|
      next unless found_type_ids.include?(type.id)
      yield(type, type.items.merge(relation).count)
    end
  end

  def unpaginaged_items
    scope = active_item_type ? active_item_type.public_items : Item.none
    scope.merge(relation)
  end

  def to_param
    query
  end

  private

  def relation
    return Item.none if query.blank?
    catalog.items.simple_search(query)
  end

  def sorted_item_types
    catalog.item_types.includes(:fields).sorted
  end
end
