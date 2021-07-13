json.data do
  json.partial! partial: 'advanced_search', locals: { advanced_search: @saved_search, advanced_search_results: @advanced_search_results }
end
