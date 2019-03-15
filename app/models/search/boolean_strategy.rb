class Search::BooleanStrategy < Search::BaseStrategy
  permit_criteria :exact, :field_condition

  def search(scope, criteria)
    negate = criteria[:field_condition] == "exclude"

    exact_search(scope, criteria[:exact], negate)
  end

  private

  def exact_search(scope, exact_phrase, negate)
    return scope if exact_phrase.blank?

    sql_operator = negate ? '<>' : '='
    scope.where("#{data_field_expr} #{sql_operator} ?", exact_phrase.strip.to_s)
  end
end
