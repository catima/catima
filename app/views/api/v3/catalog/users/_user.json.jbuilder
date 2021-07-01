json.id user.id
json.email user.email
json.language user.primary_language
json.roles user.catalog_permissions.where(catalog_id: @catalog.id)
json.last_signed_in_at user.current_sign_in_at
if json.provider
  json.provider user.provider
end
json.groups do
  json.array! user.my_groups.where(catalog_id: @catalog.id, active: true) do |group|
    json.id group.id
    json.name group.name
  end
end
