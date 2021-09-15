json.id item_type.id
json.slug item_type.slug
json.name item_type.name_translations
json.sort_fields_slugs do
  json.array! item_type.fields.select(&:human_readable?).reject(&:multiple), :slug
end
