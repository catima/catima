json.id simple_search.id
json.uuid simple_search.uuid
json.query simple_search.query
if params[:item_type_slug].present?
  json.item_type do
    json.array! simple_search_results.items.includes(:item_type).group_by(&:item_type) do |item_type, items|
      json.id item_type.id
      json.slug item_type.slug
      json.name item_type.name_translations
      json.items items, as: :item, partial: '/api/v3/catalog/item_type/items/item', locals: { with_field_values: false, with_summary: true }
    end
  end
else
  json.item_types do
    json.array! simple_search_results.item_counts_by_type do |type, count|
      json.id type.id
      json.slug type.slug
      json.count count unless @catalog.requires_review
      json.link api_v3_simple_search_url({ catalog_id: @catalog.id, uuid: simple_search.uuid, item_type_slug: type.slug })
    end
  end
end
