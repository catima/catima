class Search::DecimalStrategy < Search::BaseStrategy
  permit_criteria :exact

  def keywords_for_index(item)
    raw_value(item)
  end

  def search(scope, criteria)
    exact_search(scope, criteria[:exact])
  end

  private

  def exact_search(scope, exact_phrase)
    return scope if exact_phrase.blank?

    scope.where("#{data_field_expr} ILIKE ?", exact_phrase.strip.to_s)
  end
end
