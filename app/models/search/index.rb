# Handles extracting data from an item and building a index value that is used
# for full-text search.
class Search::Index
  attr_reader :item, :locale

  def initialize(item:, locale:)
    @item = item
    @locale = locale
  end

  def data
    # TODO
  end
end
