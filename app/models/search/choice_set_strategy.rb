class Search::ChoiceSetStrategy < Search::BaseStrategy
  include Search::MultivaluedSearch

  permit_criteria :exact, :all_words, :one_word, :less_than, :less_than_or_equal_to, :greater_than,
                  :greater_than_or_equal_to, :field_condition, :filter_field_slug, :category_field,
                  :after, :before, :between, :outside, :condition, :category_criteria => {}

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
    negate = criteria[:field_condition] == "exclude"

    if criteria[:category_field].present?
      condition = criteria[:category_criteria].keys[0]
      criteria[condition] = criteria[:category_criteria][condition]

      # Second condition may be present for ranges with DateTime fields for example
      if criteria[condition].is_a?(Hash)
        second_condition = criteria[:category_criteria].keys[1] if %w[outside between].include?(criteria[condition].keys[0])
        criteria[second_condition] = criteria[:category_criteria][second_condition]
      end

      cat_field = Field.find_by(slug: criteria[:category_field])
      return scope if cat_field.nil?

      klass = "Search::#{cat_field.type.sub(/^Field::/, '')}Strategy"
      strategy = klass.constantize.new(cat_field, locale)
      scope = strategy.search(scope, criteria)
    else
      scope = search_data_matching_one_or_more(scope, criteria[:exact], negate)
    end

    scope = search_data_matching_one_or_more(scope, criteria[:any], false) if criteria[:any].present?

    scope
  end

  private

  def choice_from_slug(slug)
    locale, name = slug.split("-", 2)
    return if name.blank?

    field.choices.short_named(name, locale).first
  end

  def search_in_category_field(scope, criteria)
    category_field = Field.find_by(slug: criteria[:category_field])

    criteria[criteria[:category_criteria].keys[0]] = criteria[:category_criteria][criteria[:category_criteria].keys[0]]

    klass = "Search::#{category_field.type.sub(/^Field::/, '')}Strategy"
    strategy = klass.constantize.new(category_field, locale)
    scope = strategy.search(
      scope.select('"parent_items".*')
        .from("items parent_items")
        .joins("LEFT JOIN items ON parent_items.data->>'#{field.uuid}' = items.id::text"),
      criteria)

    scope
  end
end
