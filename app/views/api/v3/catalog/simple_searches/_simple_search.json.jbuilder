json.id simple_search.id
json.uuid simple_search.uuid
json.query simple_search.query
json.item_types do
  json.array! simple_search_results.items.joins(:item_type).group_by(&:item_type) do |item_type, items|
    json.id item_type.id
    json.slug item_type.slug
    json.name item_type.name_translations
    json.display_emtpy_fields item_type&.display_emtpy_fields
    json.items items, as: :item, partial: '/api/v3/catalog/item_type/items/item', locals: {with_field_values: false, with_summary: true}
  end
end
