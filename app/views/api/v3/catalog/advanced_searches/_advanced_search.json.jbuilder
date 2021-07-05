json.id advanced_search.id
json.uuid advanced_search.uuid
json.item_types do
  json.array! advanced_search_results.items_grouped_by_item_types do |item_type_id, items|
    if item_type = items.first&.item_type
      json.id item_type_id
      json.slug item_type.slug
      json.set! "name_#{item_type.catalog.primary_language}", item_type.public_send("name_#{item_type.catalog.primary_language}")
      if item_type.catalog.other_languages
        item_type.catalog.other_languages do | lang |
          json.set! "name_#{lang}", item_type.public_send("name_#{lang}")
        end
      end
      json.display_emtpy_fields item_type&.display_emtpy_fields
      json.items do
        json.array! items do |item|
          json.partial! partial: '/api/v3/catalog/item_type/items/item', locals: { item: item, with_field_values: false }
        end
      end
    end
  end
end
