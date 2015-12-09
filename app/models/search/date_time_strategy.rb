class Search::DateTimeStrategy < Search::BaseStrategy
  permit_criteria :before, :after

  def keywords_for_index(_item)
    # It is not possible to search for datetime values by keyword.
    nil
  end

  def search(scope, criteria)
    scope = append_where(scope, "<", criteria[:before])
    scope = append_where(scope, ">", criteria[:after])
    scope
  end

  private

  def append_where(scope, operator, value)
    time_with_zone = field.form_submission_as_time_with_zone(value)
    return scope if time_with_zone.nil?

    scope.where(
      "cast(#{data_field_expr} AS integer) #{operator} ?",
      time_with_zone.to_i
    )
  end
end
