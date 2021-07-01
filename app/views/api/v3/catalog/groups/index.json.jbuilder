json.data do
  json.partial! 'group', collection: @groups, as: :group
end
