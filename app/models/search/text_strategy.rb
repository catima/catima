class Search::TextStrategy < Search::BaseStrategy
  include Search::I18nSearch

  permit_criteria :exact, :all_words, :one_word, :field_condition

  def keywords_for_index(item)
    text_for_keywords(item)
  end

  def search(scope, criteria)
    negate = criteria[:field_condition] == "exclude"

    scope = exact_search(scope, criteria[:exact], negate)
    scope = all_words_search(scope, criteria[:all_words], negate)
    one_word_search(scope, criteria[:one_word], negate)
  end

  private

  def text_for_keywords(item)
    field.strip_extra_content(item, locale)
  end

  def exact_search(scope, exact_phrase, negate)
    return scope if exact_phrase.blank?

    sql_operator = "#{'NOT' if negate} ILIKE"
    scope.where("#{data_field_expr} #{sql_operator} ?", exact_phrase.strip.to_s)
  end

  def one_word_search(scope, str, negate)
    return scope if str.blank?

    sql_operator = "#{'NOT' if negate} ILIKE"
    words = str.split.map(&:strip)
    sql = words.map { |_| "#{data_field_expr} #{sql_operator} ?" }.join(" OR ")
    scope.where(sql, *words.map { |w| "%#{w}%" })
  end

  def all_words_search(scope, str, negate)
    return scope if str.blank?

    sql_operator = "#{'NOT' if negate} ILIKE"
    words = str.split.map(&:strip)
    sql = words.map { |_| "#{data_field_expr} #{sql_operator} ?" }.join(" AND ")
    scope.where(sql, *words.map { |w| "%#{w}%" })
  end
end
