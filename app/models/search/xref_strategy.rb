class Search::XrefStrategy < Search::BaseStrategy
  permit_criteria :any => []

  def keywords_for_index(item)
    choice = field.selected_choice(item)
    choice ? choice.name(locale) : []
  end

  def browse(scope, choice_slug)
    choice = field.choice_by_id(choice_slug)
    return scope.none if choice.nil?
    search(scope, :any => [choice.id.to_s])
  end

  def search(scope, criteria)
    any_ids = criteria.fetch(:any, []).select(&:present?)
    return scope if any_ids.empty?
    scope.where("#{data_field_expr} IN (?)", any_ids)
  end
end
