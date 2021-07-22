json.id user.id
json.email user.email
json.language user.primary_language
json.role user_role(user, @catalog, true)
json.last_signed_in_at user.current_sign_in_at
if json.provider
  json.provider user.provider
end
json.groups do
  json.partial! '/api/v3/catalog/shared/group', collection: user.groups, as: :group
end
