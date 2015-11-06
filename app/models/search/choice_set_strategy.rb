class Search::ChoiceSetStrategy < Search::BaseStrategy
  permit_criteria :any => []

  def keywords_for_index(item)
    choice = field.selected_choice(item)
    choice ? [choice.short_name, choice.long_name] : []
  end

  def search(scope, criteria)
    any_ids = criteria.fetch(:any, []).select(&:present?)
    return scope if any_ids.empty?
    scope.where("#{data_field_expr} IN (?)", any_ids)
  end
end
