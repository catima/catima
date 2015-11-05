# Handles extracting data from an item and building a index value that is used
# for full-text search.
class Search::Index
  attr_reader :item, :locale

  def initialize(item:, locale:)
    @item = item
    @locale = locale
  end

  def data
    keywords = strategies.flat_map { |s| s.keywords_for_index(item, locale) }
    keywords.compact.join(" ")
  end

  private

  def strategies
    item.fields.map do |field|
      klass = "Search::#{field.class.name.sub(/^Field::/, '')}Strategy"
      klass.constantize.new(field)
    end
  end
end
