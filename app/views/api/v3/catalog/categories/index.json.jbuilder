json.data do
  json.partial! 'category', collection: @categories, as: :category
end
