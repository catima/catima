json.id catalog.id
json.name catalog.name
json.slug catalog.slug
json.api_enabled catalog.api_enabled
json.primary_language catalog.primary_language
json.other_languages catalog.other_languages
json.requires_review catalog.requires_review
json.catalog_access catalog_access_label(catalog)
json.is_active catalog.not_deactivated?
json.data_only catalog.data_only?
json.administrators do
  json.array! catalog.users_with_role("admin") do |user|
    json.email user.email
  end
end
