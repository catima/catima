class ItemList::Filter < ItemList
  # This is the inverse of the to_param method, below.
  def self.parse_param(param)
    field_slug, value = param.to_s.split("_", 2)
    field_slug.present? ? { :field_slug => field_slug, :value => value } : {}
  end

  include ::Search::Strategies

  attr_reader :item_type, :field, :value, :filter_field, :sort

  delegate :fields, :to => :item_type
  delegate :locale, :to => I18n

  def initialize(item_type:, field: nil, value: nil, page: nil, per: nil, filter_field: false, sort: 'ASC')
    super(item_type.catalog, page, per)
    @item_type = item_type
    @field = field
    @value = value
    @filter_field = filter_field
    @sort = sort
  end

  def unpaginaged_items
    scope = item_type.public_sorted_items
    return scope if strategy.nil?

    strategy.browse(scope, value)
  end

  def items
    return unpaginated_list_items.reorder(Arel.sql("items.data->>'#{filter_field.uuid}' #{sort || 'ASC'}")) if filter_field

    super

    if item_type.primary_human_readable_field
      unpaginated_list_items.reorder(Arel.sql("items.data->>'#{item_type.primary_human_readable_field.uuid}' #{sort || 'ASC'}"))
    else
      unpaginated_list_items
    end
  end

  def to_param
    return nil if strategy.nil?

    [field.slug, value].join("_")
  end

  private

  def strategy
    strategies.find { |s| s.field == field }
  end
end
