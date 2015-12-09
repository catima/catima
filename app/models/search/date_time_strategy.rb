class Search::DateTimeStrategy < Search::BaseStrategy
  def keywords_for_index(item)
    nil
  end

  def search(scope, criteria)
    scope
  end
end
