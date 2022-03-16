class ItemList::Filter < ItemList
  # This is the inverse of the to_param method, below.
  def self.parse_param(param)
    field_slug, value = param.to_s.split("_", 2)
    field_slug.present? ? { field_slug: field_slug, :value => value } : {}
  end

  include ::Search::Strategies

  attr_reader :item_type, :field, :value, :sort_field, :sort

  delegate :fields, :to => :item_type
  delegate :locale, :to => I18n

  def initialize(item_type:, field: nil, value: nil, page: nil, per: nil, sort_field: false, sort: 'ASC')
    super(item_type.catalog, page, per)
    @item_type = item_type
    @field = field
    @value = value
    @sort_field = sort_field || @item_type.field_for_select
    @sort = sort
  end

  def unpaginaged_items
    scope = item_type.public_sorted_items
    return scope if strategy.nil?

    strategy.browse(scope, value)
  end

  def items
    super

    field_to_sort_by = sort_field || item_type.field_for_select
    return sort_unpaginated_items(field_to_sort_by) if field_to_sort_by

    unpaginated_list_items
  end

  def to_param
    return nil if strategy.nil?

    [field&.slug, value].join("_")
  end

  private

  def sort_unpaginated_items(field)
    direction = Container::Sort.direction(sort) || sort

    case Container::Sort.type(sort)
    when Container::Sort::FIELD
      unpaginated_list_items
        .sorted_by_field(field, direction: direction)
    when Container::Sort::CREATED_AT
      unpaginated_list_items
        .sorted_by_created_at(direction: direction)
    else
      unpaginated_list_items
        .sorted_by_field(field, direction: direction)
    end
  end

  def strategy
    strategies.find { |s| s.field == field }
  end
end
