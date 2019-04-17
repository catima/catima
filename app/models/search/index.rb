# Handles extracting data from an item and building a index value that is used
# for full-text search.
class Search::Index
  include ::Search::Strategies

  attr_reader :item, :locale
  delegate :fields, :to => :item

  def initialize(item:, locale:)
    @item = item
    @locale = locale
  end

  def data
    keywords = strategies.flat_map { |s| s.keywords_for_index(item) }
    keywords.compact.join(" ")
  end
end
