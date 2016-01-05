class Search::ChoiceSetStrategy < Search::BaseStrategy
  include Search::MultivaluedSearch
  permit_criteria :any => []

  def keywords_for_index(item)
    choices = field.selected_choices(item)
    choices.flat_map { |choice| [choice.short_name, choice.long_name] }
  end

  def browse(scope, choice_slug)
    choice = choice_from_slug(choice_slug)
    return scope.none if choice.nil?
    search(scope, :any => [choice.id.to_s])
  end

  def search(scope, criteria)
    search_data_matching_one_or_more(scope, criteria[:any])
  end

  private

  def choice_from_slug(slug)
    locale, name = slug.split("-", 2)
    return if name.blank?

    field.choices.short_named(name, locale).first
  end
end
