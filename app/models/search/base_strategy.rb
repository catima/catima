# A strategy defines how a field is indexed and searched.
class Search::BaseStrategy
  attr_reader :field, :locale

  def initialize(field, locale)
    @field = field
    @locale = locale
  end

  # Returns an array of keys that can be used in the advanced search criteria
  # hash for this field.
  def criteria_keys
    []
  end

  # Returns an array of string keywords for full-text search.
  def keywords_for_index(item)
    []
  end

  private

  def raw_value(item)
    field.raw_value(item, locale)
  end
end
