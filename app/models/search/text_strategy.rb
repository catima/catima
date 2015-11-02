class Search::TextStrategy < Search::BaseStrategy
  def keywords_for_index
    raw_value
  end
end
