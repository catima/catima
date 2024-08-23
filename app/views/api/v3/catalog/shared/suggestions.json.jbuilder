json.data do
  json.array! @suggestions do |suggestion|
    json.call(suggestion, :id, :catalog_id, :item_type_id, :item_id, :user_id, :processed_at, :content)
  end
end
