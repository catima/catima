json.id simple_search.id
json.uuid simple_search.uuid
json.query simple_search.query
json.item_types do
  json.array! simple_search_results.items.select { |i| i.item_type.present? }.group_by(&:item_type_id) do |item_type_id, items|
    item_type = items.first&.item_type
    json.id item_type_id
    json.slug item_type.slug
    json.set! "name_#{item_type.catalog.primary_language}", item_type.public_send("name_#{item_type.catalog.primary_language}")
    if item_type.catalog.other_languages
      item_type.catalog.other_languages do |lang|
        json.set! "name_#{lang}", item_type.public_send("name_#{lang}")
      end
    end
    json.display_emtpy_fields item_type&.display_emtpy_fields
    json.items do
      json.array! items do |item|
        json.partial! partial: '/api/v3/catalog/item_type/items/item', locals: {item: item, with_field_values: false}
      end
    end
  end
end
