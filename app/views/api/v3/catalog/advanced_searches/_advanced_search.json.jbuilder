json.id advanced_search.id
json.uuid advanced_search.uuid
json.item_types do
  json.array! advanced_search_results.items.joins(:item_type).group_by(&:item_type) do |item_type, items|
  # json.array! advanced_search_results.items.select { |i| i.item_type.present? }.group_by(&:item_type_id) do |item_type_id, items|
    json.id item_type.id
    json.slug item_type.slug
    json.name item_type.name_translations
    json.display_emtpy_fields item_type&.display_emtpy_fields
    json.items items, as: :item, partial: '/api/v3/catalog/item_type/items/item', locals: {with_field_values: false, with_summary: true}
  end
end
