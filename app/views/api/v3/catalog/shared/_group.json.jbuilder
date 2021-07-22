json.id group.id
json.name group.name
json.description group.description
json.active group.active
json.group group.role_for_catalog(@catalog)
json.public group.public
json.users do
  json.array! group.users do |user|
    json.id user.id
    json.email user.email
  end
end
if group.public
  json.identifier group.identifier
end
