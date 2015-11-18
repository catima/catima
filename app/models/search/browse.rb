class Search::Browse < Search
  include Search::Strategies

  attr_reader :item_type, :field, :value

  delegate :fields, :to => :item_type
  delegate :locale, :to => I18n

  def initialize(item_type:, field:nil, value:nil, page:nil, per:nil)
    super(item_type.catalog, page, per)
    @item_type = item_type
    @field = field
    @value = value
  end

  def unpaginaged_items
    scope = item_type.sorted_items
    strategy = strategies.find { |s| s.field == field }
    return scope if strategy.nil?

    strategy.browse(scope, value)
  end
end
