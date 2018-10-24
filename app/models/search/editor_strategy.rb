class Search::EditorStrategy < Search::BaseStrategy
  def keywords_for_index(item)
    raw_value(item)
  end
end
