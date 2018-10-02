class Search::EmailStrategy < Search::BaseStrategy
  permit_criteria :exact, :contains, :excludes

  def keywords_for_index(item)
    raw_value(item)
  end

  def search(scope, criteria)
    scope = exact_search(scope, criteria[:exact])
    scope = contains_search(scope, criteria[:contains])
    scope = excludes_search(scope, criteria[:excludes])
    scope
  end

  private

  def exact_search(scope, exact_phrase)
    return scope if exact_phrase.blank?

    scope.where("#{data_field_expr} ILIKE ?", "%#{exact_phrase.strip}%")
  end

  def contains_search(scope, str)
    return scope if str.blank?

    words = str.split.map(&:strip)
    sql = words.map { |_| "#{data_field_expr} ILIKE ?" }.join(" AND ")
    scope.where(sql, *words.map { |w| "%#{w}%" })
  end

  def excludes_search(scope, str)
    return scope if str.blank?

    words = str.split.map(&:strip)
    sql = words.map { |_| "#{data_field_expr} ILIKE ?" }.join(" OR ")
    scope.where("NOT (#{sql})", *words.map { |w| "%#{w}%" })
  end
end
