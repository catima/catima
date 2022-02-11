json.id item_type.id
json.slug item_type.slug
json.name item_type.name_translations
json.suggestions item_type.suggestions_activated
json.suggestions_email item_type.suggestion_email
json.suggestions_allow_anonymous item_type.allow_anonymous_suggestions
json.sort_fields_slugs do
  json.array! item_type.fields.select(&:human_readable?).reject(&:multiple), :slug
end
