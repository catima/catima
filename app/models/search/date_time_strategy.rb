class Search::DateTimeStrategy < Search::BaseStrategy
  permit_criteria :before, :after

  def search(scope, criteria)
    criteria = transform_datetime_keys(criteria)
    scope = append_where(scope, "<", criteria[:before])
    scope = append_where(scope, ">", criteria[:after])
    scope
  end

  private

  # Translates the datetime_select form submission from flat into a hash with
  # numeric keys. Normally ActiveRecord does this, but since we aren't an
  # AR object, we have to do it manually.
  #
  # E.g., translates:
  #     {"before(3i)"=>"14", "before(2i)"=>"1", "before(1i)"=>"2015"}
  # Into:
  #     {"before"=>{2=>1, 1=>2015, 3=>14}}
  #
  def transform_datetime_keys(criteria)
    criteria.each_with_object({}) do |(key, value), result|
      if key.to_s =~ /^(.+)\((\d+)i\)$/
        int_or_nil = value.present? ? value.to_i : nil
        (result[$1] ||= {}).merge!($2.to_i => int_or_nil)
        result
      else
        result[key] = value
      end
    end.with_indifferent_access
  end

  def append_where(scope, operator, value)
    time_with_zone = field.form_submission_as_time_with_zone(value)
    return scope if time_with_zone.nil?

    scope.where(
      "cast(#{data_field_expr} AS integer) #{operator} ?",
      time_with_zone.to_i
    )
  end
end
