class Search::References < Search::Browse
  attr_reader :item
  delegate :to_param, :to => :item

  def initialize(item:, field:, page:nil, per:nil)
    super(
      :item_type => field.item_type,
      :field => field,
      :value => item.id.to_s,
      :page => page,
      :per => per || 8
    )
    @item = item
  end
end
