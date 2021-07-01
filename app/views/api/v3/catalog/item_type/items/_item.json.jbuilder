json.id item.id
json.item_type_id item.item_type_id
json.created_at item.created_at
json.updated_at item.updated_at
json.field_values do
  json.array! item.item_type.fields do |field|
    json.value item.data["#{field.uuid}"]
    json.field do
      json.partial! '/api/v3/catalog/shared/field', field: field
    end
    json.review_status item.review_status if item.catalog.requires_review
  end
end
