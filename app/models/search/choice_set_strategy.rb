class Search::ChoiceSetStrategy < Search::BaseStrategy
  permit_criteria :any

  def keywords_for_index(item)
    choice = field.selected_choice(item)
    choice ? [choice.short_name, choice.long_name] : []
  end

  def search(scope, criteria)
    # TODO
    scope
  end
end
