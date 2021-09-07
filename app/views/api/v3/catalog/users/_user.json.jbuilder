json.id user.id
json.email user.email
json.language user.primary_language
json.role do
  json.role user_role_symbol(user, @catalog, true)
  json.group_id user_role_id(user, @catalog)
end
json.last_signed_in_at user.current_sign_in_at
if json.provider
  json.provider user.provider
end
json.groups do
  json.partial! partial: '/api/v3/catalog/shared/group', collection: user.groups, as: :group, locals: {with_users: false}
end
