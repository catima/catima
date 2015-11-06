# A strategy defines how a field is indexed and searched.
class Search::BaseStrategy
  attr_reader :field, :locale

  def self.permit_criteria(*args)
    @permitted_keys = args
  end

  def initialize(field, locale)
    @field = field
    @locale = locale
  end

  # Returns an array of keys that can be used in the advanced search criteria
  # hash for this field, suitable for passing to strong parameters' `permit`.
  def permitted_keys
    self.class.instance_variable_get(:@permitted_keys) || []
  end

  # Returns an array of string keywords for full-text search.
  def keywords_for_index(_item)
    []
  end

  # Appends field-specific clauses to the given Item scope based on a hash of
  # search criteria.
  def search(scope, _criteria)
    scope
  end

  private

  def raw_value(item)
    field.raw_value(item, locale)
  end
end
