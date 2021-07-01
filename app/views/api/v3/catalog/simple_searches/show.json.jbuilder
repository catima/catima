json.data do
  json.partial! partial: 'simple_search', locals: {simple_search: @simple_search, simple_search_results: @simple_search_results}
end
