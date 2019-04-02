class Search::DecimalStrategy < Search::BaseStrategy
  include Search::NumberedSearch

  permit_criteria :exact, :less_than, :less_than_or_equal_to, :greater_than, :greater_than_or_equal_to, :field_condition

  def keywords_for_index(item)
    raw_value(item)
  end

  def search(scope, criteria)
    negate = criteria[:field_condition] == "exclude"

    scope = append_where_number_is_set(scope) unless negate

    scope = exact_search(scope, criteria[:exact], negate)
    scope = less_than_search(scope, criteria[:less_than], negate, "float")
    scope = less_than_or_equal_to_search(scope, criteria[:less_than_or_equal_to], negate, "float")
    scope = greater_than_search(scope, criteria[:greater_than], negate, "float")
    scope = greater_than_or_equal_to_search(scope, criteria[:greater_than_or_equal_to], negate, "float")
    scope
  end
end
