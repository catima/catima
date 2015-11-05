# A strategy defines how a field is indexed and searched.
class Search::BaseStrategy
  attr_reader :field

  def initialize(field)
    @field = field
  end

  # Returns an array of string keywords for full-text search.
  def keywords_for_index(item, locale)
    []
  end

  private

  def raw_value(item, locale)
    field.raw_value(item, locale)
  end
end
