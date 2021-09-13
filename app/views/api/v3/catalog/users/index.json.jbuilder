json.data do
  json.partial! 'user', collection: @users, as: :user
end
