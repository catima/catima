class Search::ReferenceStrategy < Search::BaseStrategy
  include Search::MultivaluedSearch

  def browse(scope, item_id)
    search_data_matching_one_or_more(scope, item_id)
  end
end
