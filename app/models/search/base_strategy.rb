# A strategy defines how a field is indexed and searched.
class Search::BaseStrategy
  attr_reader :item, :field, :locale

  def initialize(item, field, locale)
    @item = item
    @field = field
    @locale = locale
  end

  # Returns an array of string keywords for full-text search.
  def keywords_for_index
    []
  end

  private

  def raw_value
    field.raw_value(item, locale)
  end
end
