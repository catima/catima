json.id group.id
json.name group.name
json.description group.description
json.is_active group.active
json.is_public group.public
json.role group.role_for_catalog(@catalog)
if with_users
  json.users do
    json.array! group.users do |user|
      json.id user.id
      json.email user.email
    end
  end
else
  json.role
end
json.identifier group.identifier if group.public
