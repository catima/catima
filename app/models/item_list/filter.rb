class ItemList::Filter < ItemList
  # This is the inverse of the to_param method, below.
  def self.parse_param(param)
    field_slug, value = param.to_s.split("_", 2)
    field_slug.present? ? { field_slug: field_slug, :value => value } : {}
  end

  include ::Search::Strategies

  attr_reader :item_type, :field, :value, :sort_type, :sort_field, :sort

  delegate :locale, :to => I18n

  def initialize(item_type:, field: nil, value: nil, page: nil, per: nil, sort_type: nil, sort_field: false, sort: 'ASC')
    super(item_type.catalog, page, per)
    @item_type = item_type
    @field = field
    @value = value
    @sort_type = sort_type
    @sort_field = sort_field || @item_type.field_for_select
    @sort = sort
  end

  def unpaginaged_items
    scope = strategy.nil? ? item_type.public_items : strategy.browse(item_type.public_items, value)
    scope = apply_sorting(scope)
    # Add secondary sort by ID for deterministic ordering, matching the primary sort direction
    scope.order(id: sort&.upcase == 'DESC' ? :desc : :asc)
  end

  def items
    super # unpaginaged_items now has correct sorting, just apply pagination
  end

  def to_param
    return nil if strategy.nil?

    [field&.slug, value].join("_")
  end

  def items_for_navigation
    @items_for_navigation ||= unpaginaged_items.includes(:item_type, :item_type => :fields)
  end

  private

  def apply_sorting(scope)
    field_to_sort_by = sort_field || item_type.field_for_select
    return scope.sorted_by_field(item_type.primary_field) if field_to_sort_by.nil? && item_type.primary_field
    return scope unless field_to_sort_by

    container_sort? ? apply_container_sort(scope, field_to_sort_by) : scope.sorted_by_field(field_to_sort_by, direction: sort)
  end

  def container_sort?
    Container::Sort.type(sort_type).present?
  end

  def apply_container_sort(scope, field)
    case Container::Sort.type(sort_type)
    when Container::Sort::FIELD
      scope.sorted_by_field(field, direction: sort)
    when Container::Sort::CREATED_AT
      scope.sorted_by_created_at(direction: sort)
    when Container::Sort::UPDATED_AT
      scope.sorted_by_updated_at(direction: sort)
    else
      scope.sorted_by_field(field, direction: sort)
    end
  end

  def strategy
    strategies.find { |s| s.field.uuid == field&.uuid }
  end

  def fields
    item_type.all_fields
  end
end
