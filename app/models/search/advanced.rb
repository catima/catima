# Wraps the AdvancedSearch ActiveRecord model with all the actual logic for
# performing the search and paginating the results.
#
class Search::Advanced < Search
  attr_reader :model
  delegate :catalog, :item_type, :criteria, :to => :model

  def initialize(model:, page:nil, per:nil)
    super(model.catalog, page, per)
    @model = model
  end

  private

  def unpaginaged_items
    item_type.sorted_items
  end
end
