class Search::ChoiceSetStrategy < Search::BaseStrategy
  include Search::MultivaluedSearch

  permit_criteria :exact, :all_words, :one_word, :less_than, :less_than_or_equal_to, :greater_than,
                  :greater_than_or_equal_to, :field_condition, :filter_field_slug, :category_field,
                  :after, :before, :between, :outside, :condition, :default, :category_criteria => {}

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

      register_second_condition(criteria, condition)

      cat_field = Field.find_by(uuid: criteria[:category_field])
      return scope if cat_field.nil?

      if cat_field.type == "Field::ChoiceSet"
        @field = cat_field
        scope = search_data_matching_one_or_more(scope, criteria[:default], negate)
      else
        klass = "Search::#{cat_field.type.sub(/^Field::/, '')}Strategy"
        strategy = klass.constantize.new(cat_field, locale)
        scope = strategy.search(scope, criteria)
      end
    else
      scope = search_data_matching_one_or_more(scope, criteria[:default], negate)
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

  def register_second_condition(criteria, condition)
    return unless criteria[condition].is_a?(Hash)

    # Second condition may be present for ranges with DateTime fields for example
    second_condition = criteria[:category_criteria].keys[1] if %w[outside between].include?(criteria[condition].keys[0])
    criteria[second_condition] = criteria[:category_criteria][second_condition]
  end
end
