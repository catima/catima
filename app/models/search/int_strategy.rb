class Search::IntStrategy < Search::BaseStrategy
  include Search::NumberedSearch

  permit_criteria :exact, :less_than, :less_than_or_equal_to, :greater_than, :greater_than_or_equal_to, :field_condition

  def keywords_for_index(item)
    raw_value(item)
  end

  def search(scope, criteria)
    negate = criteria[:field_condition] == "exclude"

    scope = exact_search(scope, criteria[:exact], negate)
    scope = less_than_search(scope, criteria[:less_than], negate)
    scope = less_than_or_equal_to_search(scope, criteria[:less_than_or_equal_to], negate)
    scope = greater_than_search(scope, criteria[:greater_than], negate)
    scope = greater_than_or_equal_to_search(scope, criteria[:greater_than_or_equal_to], negate)
    scope
  end
end
