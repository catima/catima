json.id catalog.id
json.name catalog.name
json.slug catalog.slug
json.api_enabled catalog.api_enabled
json.primary_language catalog.primary_language
json.other_languages catalog.other_languages
json.requires_review catalog.requires_review
json.advertize catalog.advertize
json.catalog_access catalog_access(catalog)
json.custom_root_page_id catalog.custom_root_page_id
json.administrators do
  json.array! catalog.users_with_role("admin") do |user|
    json.email user.email
  end
end
