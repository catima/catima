class Search::Browse < Search
  include Search::Strategies

  attr_reader :field, :value
  delegate :item_type, :to => :field
  delegate :fields, :to => :item_type
  delegate :locale, :to => I18n

  def initialize(field:, value:)
    @field = field
    @value = value
  end

  def unpaginaged_items
    strategy = strategies.find { |s| s.field == field }
    strategy.browse(item_type.sorted_items, value)
  end
end
