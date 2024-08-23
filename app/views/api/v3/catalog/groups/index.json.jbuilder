json.data do
  json.partial! partial: '/api/v3/catalog/shared/group', collection: @groups, as: :group, locals: { with_users: true }
end
