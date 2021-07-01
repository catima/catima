json.id simple_search.id
json.uuid simple_search.uuid
json.query simple_search.query

json.item_types do
  json.array! simple_search_results.items_grouped_by_item_types do |item_type_id, items|
    json.item_type_id item_type_id
    json.items do
      json.array! items do |item|
        json.partial! '/api/v3/catalog/item_type/items/item', item: item
      end
    end
  end
end
