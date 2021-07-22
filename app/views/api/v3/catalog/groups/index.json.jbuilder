json.data do
  json.partial! '/api/v3/catalog/shared/group', collection: @groups, as: :group
end
