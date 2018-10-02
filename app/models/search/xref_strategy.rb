class Search::XrefStrategy < Search::BaseStrategy
  include Search::MultivaluedSearch
  permit_criteria :any => []

  def keywords_for_index(item)
    choices = field.selected_choices(item)
    choices.map { |c| c.name(locale) }
  end

  def browse(scope, choice_slug)
    choice = field.choice_by_id(choice_slug)
    return scope.none if choice.nil?

    search(scope, :any => [choice.id.to_s])
  end

  def search(scope, criteria)
    search_data_matching_one_or_more(scope, criteria[:any])
  end
end
